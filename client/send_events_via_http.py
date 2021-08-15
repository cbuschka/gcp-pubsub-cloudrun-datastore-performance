import aiohttp
import asyncio
import base64
import json
import os
import random
import uuid

from gcloud.aio.run import RunClient

random.seed()

project = os.environ["GCP_PROJECT"]
region = os.environ.get("REGION", "europe-west3")
prefix = os.environ.get("PREFIX", "")
print("Project is {}".format(project))


async def get_cloud_run_endpoint():
  async with aiohttp.ClientSession() as session:
    async with RunClient(session=session) as client:
      services = await client.list_services(project, region=region)
      for service in services:
        if service.name == f'{prefix}gpcdp-service':
          return service.url


async def main():
  endpoint_url = await get_cloud_run_endpoint()
  print(f"Service is reachable via {endpoint_url}")

  message_count = 1
  event_count_each = 10_000
  await asyncio.gather(
    *[post_events(event_count_each, endpoint_url=f'{endpoint_url}/events') for _
      in
      range(message_count)])


async def post_events(event_count, *, endpoint_url=None):
  async with aiohttp.ClientSession() as session:
    items = [{"id": random.randint(0, 9999999999),
              "value": "value{}".format(random.randint(0, 9999999999))} for _ in
             range(event_count)]
    message = {"batchId": str(uuid.uuid4()), "items": items}
    pubsub_message = {"message": {
      "data": base64.encodebytes(json.dumps(message).encode("utf-8")).decode(
        "utf-8")}}
    async with session.post(endpoint_url, data=json.dumps(pubsub_message),
                            headers={
                              "Content-Type": "application/json"}) as response:
      try:
        body = await response.json()
        if "results" in body:
          del body["results"]
        print(body)
      except (aiohttp.client_exceptions.ContentTypeError):
        body = await response.text()
        print(body)


if __name__ == '__main__':
  asyncio.run(main())
