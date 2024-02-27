import { cloud } from "@wingcloud/framework";
import { Hono } from "hono";
import type { FC } from 'hono/jsx'

export const myServer = async ({ bucket }: { bucket: cloud.IBucketClient }) => {
  const file = await bucket.get("hello");
  console.log(file);
  return file;
}

export const app = new Hono()

const Layout: FC = (props) => {
  return (
    <html>
      <body>{props.children}</body>
    </html>
  )
}

const Top: FC<{ messages: string[] }> = (props: { messages: string[] }) => {
  return (
    <Layout>
      <h1>Hello Hono!</h1>
      <ul>
        {props.messages.map((message) => {
          return <li>{message}!!</li>
        })}
      </ul>
    </Layout>
  )
}

app.get('/', (c) => {
  const messages = ['Good Morning', 'Good Evening', 'Good Night']
  return c.html(<Top messages={messages} />)
})

app.get('/api', (c) => {
  return c.json({ message: 'Hello World!' })
})
