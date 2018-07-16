import choo from 'choo'
import { mainStore } from './app/store'
import { sidebarStore } from './app/sidebar/store'
import { mainView } from './app/view'

const app = choo()

if (process.env.NODE_ENV !== 'production') {
  app.use(require('choo-devtools')())
}

app.use(mainStore)
app.use(sidebarStore)

// FIXME: eventually we should have real URLs that indicate the UI state
app.route('*', (state, emit) => {
  return mainView(state, emit)
})

app.mount('.editor')

// TODO: make a helpers.js and put this in there
// function url (...paths) {
//   return ['/app/editor'].concat(paths).join('/')
// }

