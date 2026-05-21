import os
import time
from pathlib import Path
from fastapi import FastAPI, UploadFile, HTTPException
from fastapi.responses import HTMLResponse, Response
from azure.storage.blob import BlobServiceClient
from azure.core.exceptions import ResourceNotFoundError
from dotenv import load_dotenv

load_dotenv()

app = FastAPI()

AZURE_STORAGE_CONNECTION_STRING = os.getenv("AZURE_STORAGE_CONNECTION_STRING")
INPUT_CONTAINER = os.getenv("AZURE_CONTAINER_NAME")
OUTPUT_CONTAINER = os.getenv("AZURE_OUTPUT_CONTAINER")

POLL_INTERVAL_SECONDS = 0.5
POLL_TIMEOUT_SECONDS = 30


@app.post("/upload")
async def upload_file(file: UploadFile):

    try: 
        blob_service = BlobServiceClient.from_connection_string(AZURE_STORAGE_CONNECTION_STRING)

        contents = await file.read()
        source_blob = blob_service.get_blob_client(
            container=INPUT_CONTAINER, blob=file.filename
        )
        source_blob.upload_blob(contents, overwrite=True)

        output_name = Path(file.filename).stem + ".jpg"
        dest_blob=blob_service.get_blob_client(
            container=OUTPUT_CONTAINER, blob=output_name
        )

        deadline = time.time() + POLL_TIMEOUT_SECONDS
        while time.time() < deadline:
            try:
                jpg_data =  dest_blob.download_blob().readall()
                return Response(
                    content=jpg_data,
                    media_type="image/jpeg",
                    headers={
                        "Content-Disposition": f'attachment; filename "{output_name}"'
                    }

                )
            except ResourceNotFoundError:
                time.sleep(POLL_INTERVAL_SECONDS)

        raise HTTPException(
            status_code=504,
            detail="Time out."
        )    
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail = str(e))
    
@app.get("/", response_class=HTMLResponse)
def home():
     return """
    <!DOCTYPE html>
    <html>
    <head><title>File Upload</title></head>
    <body>
        <h1>Upload a File to Azure</h1>
        <form action="/upload" method="post" enctype="multipart/form-data">
            <input type="file" name="file">
            <button type="submit">Upload</button>
        </form>
    </body>
    </html>
    """