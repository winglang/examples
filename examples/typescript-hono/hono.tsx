import { cloud } from "@wingcloud/framework";
import { Hono } from "hono";
import type { FC } from 'hono/jsx'

type Bindings = {
  BUCKET: cloud.IBucketClient
}

export const app = new Hono<{ Bindings: Bindings }>();

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

app.get('/', async (c) => {
  const bucket = c.env.BUCKET;
  const messages = ['Good Morning', 'Good Evening', 'Good Night', await bucket.get('hello')]
  return c.html(<Top messages={messages} />)
})

app.get('/api', (c) => {
  return c.json({ message: 'Hello World!' })
})

app.post('/api', (c) => {
  return c.json({ message: 'Posted' })
})
