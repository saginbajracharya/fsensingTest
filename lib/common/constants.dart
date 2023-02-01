String baseUrl = 'https://dev3.yigserver.com/apps/fsensing/public/api/v1/'; //live

// String baseUrl = 'https://dev3.yigserver.com/apps/fsensing_stg/public/api/v1/'; //stg

Map firebaseCollection = {
  'history': 'worker_status_history',
  'latest': 'worker_status_latest',
  'latest2': 'worker_status_latest2',
  'deviceStatusHistory': 'device_status_history',
  'deviceStatusLatest': 'device_status_latest',
  'masterWorker': 'master_worker',
  'alertLog':'alert_log',
};