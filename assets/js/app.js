import html from 'choo/html'
import choo from 'choo'
import { css } from 'emotion'

const app = choo()

if (process.env.NODE_ENV !== 'production') {
  app.use(require('choo-devtools')())
}

app.use(store)

app.route('/app/editor', (state, emit) => {
  return mainView(state, emit)
})

app.route('/app/editor/edit/*', (state, emit) => {
  return mainView(state, emit)
})

app.mount('.editor')

// function url (...paths) {
//   return ['/app/editor'].concat(paths).join('/')
// }

function mainView (state, emit) {
  return html`
    <div class="editor">
      <div class="topbar">${editorTopbarView(state, emit)}</div>
      <div class="sidebar">
        ${sectionList(state, [], emit)}
      </div>
      ${singleView(state, emit)}
    </div>
  `
}

function editorTopbarView (state, emit) {
  return html`
    <nav class=${css`
      background-color: black;
      color: white;
    `}>
      Top bar
    </nav>
  `
}

function sectionList (state, sections, emit) {
  if (sections.length === 0) {
    return ''
  } else {
    return html`
      <ul class="sections">
        ${sections.map(section => section.title)}
      </ul>
    `
  }
}

function singleView (state, emit) {
  if (state.selectedContent) {
    return html`
      <div class="single">
        <h2>${state.selectedContent.title}</h2>
        <div class="controls">
          Controles
        </div>
      </div>
    `
  } else {
    return html`
      <div class="single"></div>
    `
  }
}

function store (state, emitter) {
  state.content = {
    content: {
      markdown: {
        id: '_index.md',
        path: 'content/_index.md',
        data: '',
        body: '',
        frontmatter: {}
      },
      sections: [],
      pages: [],
      resources: [],
      children: []
    },
    byPath: {}
  }

  // Edits are stored by the path index of the edited content
  state.edits = {}
  state.selectedContentPath = null

  emitter.on('content:edit', ({ path, value }) => {
    state.edits[path] = value
  })

  console.debug('state', state)
}
