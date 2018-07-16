import html from 'nanohtml'
import { css } from 'emotion'

export function mainView (state, emit) {
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

