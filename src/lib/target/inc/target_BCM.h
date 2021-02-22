#ifndef TARGET_BCM_H_INCLUDED
#define TARGET_BCM_H_INCLUDED

#include "schema.h"

#include "wl80211.h"
#include "wl80211_client.h"
#include "wl80211_scan.h"
#include "wl80211_survey.h"

#define TARGET_CERT_PATH            "/var/certs"
#define TARGET_MANAGERS_PID_PATH    "/var/run/plume"
#define TARGET_OVSDB_SOCK_PATH      "/var/run/db.sock"
#define TARGET_LOGREAD_FILENAME     "/var/log/messages"

typedef wl80211_client_record_t target_client_record_t;
typedef wl80211_survey_record_t target_survey_record_t;
typedef void target_capacity_data_t;

#include "target_common.h"

#endif /* TARGET_BCM_H_INCLUDED */
