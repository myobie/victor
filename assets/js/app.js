import choo from 'choo'
import { store } from './store'
import { mainView } from './main-view'

const app = choo()

if (process.env.NODE_ENV !== 'production') {
  app.use(require('choo-devtools')())
}

app.use(store)

// FIXME: eventually we should have real URLs that indicate the UI state
app.route('*', (state, emit) => {
  return mainView(state, emit)
})

app.mount('.editor')

// TODO: make a helpers.js and put this in there
// function url (...paths) {
//   return ['/app/editor'].concat(paths).join('/')
// }

