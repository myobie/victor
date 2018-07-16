const emptyContent = {
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
}

export function store (state, emitter) {
  state.content = window.bootstrapContent || emptyContent

  // Edits are stored by the path index of the edited content
  state.edits = {}
  state.selectedContent = null

  emitter.on('content:edit', ({ path, value }) => {
    state.edits[path] = value
  })

  console.debug('state', state)
}
