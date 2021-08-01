from gcloud.aio.pubsub import PubsubMessage
from gcloud.aio.pubsub import PublisherClient
import aiohttp
import asyncio
import os
import random
import json

random.seed()

project = os.environ["GCP_PROJECT"]
print("Project is {}".format(project))
topic_name = "conni-gpcdp-input"


async def main():
  message_count = 1
  event_count_each = 10
  await asyncio.gather(
    *[send_pubsub_message(event_count_each) for _ in range(message_count)])


async def send_pubsub_message(event_count):
  async with aiohttp.ClientSession() as session:
    client = PublisherClient(session=session)
    topic = client.topic_path(project, topic_name)

    items = [{"id": random.randint(0, 9999999999),
              "value": "value{}".format(random.randint(0, 9999999999))} for _ in
             range(event_count)]
    message = {"items": items}
    pubsub_messages = [
      PubsubMessage(json.dumps(message)),
    ]
    response = await client.publish(topic, pubsub_messages)
    print(response)
    return response


if __name__ == '__main__':
  asyncio.run(main())
