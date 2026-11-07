// Privacy settings for every Sentry.init in a browser or Next.js app.
// Template from the web-app-stack skill (assets/sentry-privacy.ts).
// Spread into each init:
//
//   Sentry.init({ dsn, environment, release, ...sentryPrivacy, ... });
//
// For Next.js, import from '@sentry/nextjs' instead and spread it into the
// client, server and edge inits alike.
import type * as Sentry from '@sentry/react';

type Options = NonNullable<Parameters<typeof Sentry.init>[0]>;
type StreamedSpanJSON = Parameters<NonNullable<Options['beforeSendSpan']>>[0];
type ErrorEvent = Sentry.ErrorEvent;

// Passing dataCollection at all turns every category not named here to its
// permissive default, so each one is named: no user fields, bodies (login
// forms carry passwords), cookies, query strings (reset links carry tokens),
// or headers carrying the visitor's IP (Caddy sets X-Forwarded-For).
const IP_HEADERS = ['forwarded', '-ip', 'remote-', 'via', '-user'];

const dataCollection = {
  userInfo: false,
  httpBodies: [],
  httpHeaders: { deny: IP_HEADERS },
  cookies: false,
  urlQueryParams: false,
  graphQL: { document: false, variables: false },
  genAI: { inputs: false, outputs: false },
  databaseQueryData: false,
  queues: false,
} satisfies Options['dataCollection'];

// The scrubbers below are the last line of defence before anything leaves:
// in @sentry/nextjs 11.11 the query string still reached Sentry in Next.js's
// own `http.target` span attribute despite dataCollection, and IP headers and
// addresses are dropped as a backstop.

// Last line of defence before anything leaves for Sentry, in every runtime.
// `dataCollection` (sentry.shared.ts) covers headers, cookies and the SDK's own
// URL fields, but in @sentry/nextjs 11.11 the query string still reaches Sentry
// in Next.js's `http.target` span attribute. Query strings must go: reset links
// carry tokens and search URLs carry what members typed. IP headers and
// addresses are dropped here too, as a backstop: Caddy sets X-Forwarded-For to
// the visitor's address.

const IP_HEADER = /forwarded|-ip$|^remote-|^via$|-user$|^true-client|^cf-connecting/i;
const IP_ATTRIBUTES = new Set([
  'client.address',
  'network.peer.address',
  'user.ip_address',
  'http.client_ip',
]);
const URL_ATTRIBUTES = new Set(['url.full', 'http.url', 'http.target', 'url']);

export function stripQuery(url: string): string {
  return url.replace(/[?#].*$/, '');
}

function scrubAttribute(key: string, value: unknown): unknown {
  if (key === 'url.query' || IP_ATTRIBUTES.has(key)) return undefined;
  const header = key.match(/^http\.(?:request|response)\.header\.(.+)$/);
  if (header && IP_HEADER.test(header[1])) return undefined;
  if (URL_ATTRIBUTES.has(key)) {
    if (typeof value === 'string') return stripQuery(value);
    if (value && typeof value === 'object' && 'value' in value) {
      const inner = (value as { value: unknown }).value;
      if (typeof inner === 'string') return { ...value, value: stripQuery(inner) };
    }
  }
  return value;
}

export function scrubSpan(span: StreamedSpanJSON): StreamedSpanJSON {
  const attributes: StreamedSpanJSON['attributes'] = {};
  for (const [key, value] of Object.entries(span.attributes ?? {})) {
    const scrubbed = scrubAttribute(key, value);
    if (scrubbed !== undefined) attributes[key] = scrubbed as never;
  }
  return { ...span, name: stripQuery(span.name), attributes };
}

export function scrubEvent(event: ErrorEvent): ErrorEvent {
  if (event.request) {
    delete event.request.query_string;
    delete event.request.cookies;
    if (event.request.url) event.request.url = stripQuery(event.request.url);
    if (event.request.headers) {
      for (const name of Object.keys(event.request.headers)) {
        if (IP_HEADER.test(name)) delete event.request.headers[name];
      }
    }
  }
  if (event.user) delete event.user.ip_address;
  for (const crumb of event.breadcrumbs ?? []) {
    for (const key of ['url', 'to', 'from'] as const) {
      const value = crumb.data?.[key];
      if (typeof value === 'string') crumb.data![key] = stripQuery(value);
    }
  }
  return event;
}

export const sentryPrivacy = {
  dataCollection,
  beforeSend: scrubEvent,
  beforeSendSpan: scrubSpan,
};
