import { cloud } from "@wingcloud/framework";

export const myServer = async ({bucket}: { bucket: cloud.IBucketClient }) => {
  const file = await bucket.get("hello");
  console.log(file);
  return file;
}