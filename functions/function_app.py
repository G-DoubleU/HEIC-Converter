import azure.functions as func
import io
import logging
import os
from azure.storage.blob import BlobServiceClient
from PIL import Image
import pillow_heif

pillow_heif.register_heif_opener()

app = func.FunctionApp()

@app.event_grid_trigger(arg_name="azeventgrid")
def OnFileUpload(azeventgrid: func.EventGridEvent):
    logging.info("=" * 50)
    logging.info(f"Event type: {azeventgrid.event_type}")
    logging.info(f"Subject: {azeventgrid.subject}")
    logging.info("=" * 50)

    if azeventgrid.event_type != "Microsoft.Storage.BlobCreated":
        logging.info("This is not a blob creation event, skipping")
        return
    
    subject_parts = azeventgrid.subject.split("/")
    container_name = subject_parts[4]
    blob_name = subject_parts[6]

    if not blob_name.lower().endswith((".heic", ".heif")):
        logging.info(f"File is non-heic. {blob_name}")
        return
    
    connection_string = os.environ["BLOB_STORAGE_CONNECTION"]
    input_container = os.environ["INPUT_CONTAINER"]
    output_container = os.environ["OUTPUT_CONTAINER"]

    if container_name != input_container:
        logging.info(f"File uploaded in unexpected container")
        return 
    
    blob_service = BlobServiceClient.from_connection_string(connection_string)
    source_blob = blob_service.get_blob_client(
        container=input_container, blob=blob_name
    )

    logging.info(f"Downloading: {blob_name}")
    heic_bytes = source_blob.download_blob().readall()

    logging.info("Converting to .jpg")
    image = Image.open(io.BytesIO(heic_bytes))
    jpg_buffer = io.BytesIO()
    image.convert("RGB").save(jpg_buffer, format="JPEG", quality=90)
    jpg_bytes = jpg_buffer.getvalue()

    output_name = blob_name.rsplit(".", 1)[0] + ".jpg"

    dest_blob = blob_service.get_blob_client(container=output_container, blob=output_name)

    dest_blob.upload_blob(jpg_bytes, overwrite=True)

    logging.info("Conversion Complete")




             
