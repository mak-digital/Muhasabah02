/**
 * Cloudflare Worker entry. Named exports are not allowed here (workerd).
 * Logic: ./logic.js
 */
import { handleRequest } from './logic.js';

export default {
  async fetch(request, env) {
    return handleRequest(request, env, globalThis.fetch);
  },
};
