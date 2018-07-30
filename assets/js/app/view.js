import html from 'nanohtml'
import { css } from 'emotion'
import { sidebarView } from './sidebar/view'

export function mainView (state, emit) {
  return html`
    <div class=${css`
      width: 100vw;
      height: 100vh;
      overflow: hidden;
    `}>
      <div class=${css`
        height: 50px;
      `}>
        ${editorTopbarView(state, emit)}
      </div>
      <div class=${css`
        width: 360px;
        height: 90%;
        height: calc(100vh - 50px);
      `}>
        ${sidebarView(state.sidebar, emit)}
      </div>
      <div class=${css`
        margin-left: 360px;
        height: 90%;
        height: calc(100vh - 50px);
      `}>
        ${singleView(state, emit)}
      </div>
    </div>
  `
}

function editorTopbarView (state, emit) {
  return html`
    <nav class=${css`
      height: 100%;
      background-color: black;
      color: white;
    `}>
      Top bar
    </nav>
  `
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
