// Module imports.
import {headers, checkStatus} from '../../utils/fetch';

export const fetchManifests = (exchange) => {
  let route_opts = {
    credentials: 'same-origin',
    method: 'GET',
    headers: headers('json', 'csrf')
  };

  let exchangePromise = exchange
    .fetch(Routes.fetch_manifests_path(CONFIG.project_name), route_opts)
    .then(checkStatus);

  return exchangePromise;
};

export const createManifest = (manifest, exchange) => {
  let route_opts = {
    credentials: 'same-origin',
    method: 'POST',
    headers: headers('json', 'csrf'),
    body: JSON.stringify(manifest)
  };

  let exchangePromise = exchange
    .fetch(Routes.create_manifest_path(CONFIG.project_name), route_opts)
    .then(checkStatus);

  return exchangePromise;
};

export const updateManifest = (manifestUpdates, manifest_id, exchange) => {
  let route_opts = {
    credentials: 'same-origin',
    method: 'POST',
    headers: headers('json', 'csrf'),
    body: JSON.stringify(manifestUpdates)
  };

  let exchangePromise = exchange
    .fetch(
      Routes.update_manifest_path(CONFIG.project_name, manifest_id),
      route_opts
    )
    .then(checkStatus);

  return exchangePromise;
};

export const destroyManifest = (manifest_id, exchange) => {
  let route_opts = {
    credentials: 'same-origin',
    method: 'DELETE',
    headers: headers('json', 'csrf')
  };

  let exchangePromise = exchange
    .fetch(
      Routes.destroy_manifest_path(CONFIG.project_name, manifest_id),
      route_opts
    )
    .then(checkStatus);

  return exchangePromise;
};

export const getConsignments = (queries, exchange) => {
  let route_opts = {
    method: 'POST',
    credentials: 'same-origin',
    headers: headers('json', 'csrf'),
    body: JSON.stringify({queries})
  };

  let exchangePromise = exchange
    .fetch(Routes.consignment_path(CONFIG.project_name), route_opts)
    .then(checkStatus);

  return exchangePromise;
};

export const getConsignmentsByManifestId = (
  manifest_ids,
  record_name,
  exchange
) => {
  let route_opts = {
    method: 'POST',
    credentials: 'same-origin',
    headers: headers('json', 'csrf'),
    body: JSON.stringify({manifest_ids, record_name})
  };

  let exchangePromise = exchange
    .fetch(Routes.consignment_path(CONFIG.project_name), route_opts)
    .then(checkStatus);

  return exchangePromise;
};
