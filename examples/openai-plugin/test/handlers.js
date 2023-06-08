import { rest } from 'msw'

export const handlers = [
  rest.get('https://api.github.com/repos/winglang/wing/issues', (req, res, ctx) => {
    return res(
      ctx.status(200),
      ctx.json([])
    )
  }),
]