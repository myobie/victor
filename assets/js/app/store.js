import { assignCID } from './cid'

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

export function mainStore (bootstrapContent) {
  return (state, emitter) => {
    state.content = assignCID(bootstrapContent || emptyContent)

    // Edits are stored by the path index of the edited content
    state.edits = {}
    state.selectedContent = null

    emitter.on('content:edit', ({ path, value }) => {
      state.edits[path] = value
    })

    console.debug('state', state)
  }
}
