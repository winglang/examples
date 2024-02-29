import { cloud } from "@wingcloud/framework";

export const myServer = async ({bucket}: { bucket: cloud.Bucket }) => {
  const inflightBucket = bucket as unknown as cloud.IBucketClient
  const file = await inflightBucket.get("hello");
  console.log(file);
  return file;
}