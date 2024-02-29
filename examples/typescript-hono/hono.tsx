import type { cloud } from "@wingcloud/framework";
import { Hono } from "hono";
import type { FC } from 'hono/jsx'

type Bindings = {
  BUCKET: cloud.IBucketClient
}

const env = process.env.WING_TARGET; // Handle the /prod prefix from the API Gateway for tf-aws
const basePath = env === 'tf-aws' ? '/prod/' : '';

export const app = new Hono<{ Bindings: Bindings }>().basePath(basePath);

app.use(async (c, next) => {
  console.log(`[${c.req.method}] ${c.req.url} ${c.req.path} ${c.req.routePath} ${c.req.matchedRoutes}`)
  await next()
})

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
