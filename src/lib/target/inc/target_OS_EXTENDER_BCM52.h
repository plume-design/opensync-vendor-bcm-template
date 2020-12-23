#ifndef TARGET_OS_EXTENDER_BCM52_H_INCLUDED
#define TARGET_OS_EXTENDER_BCM52_H_INCLUDED

#include "schema.h"

#include "wl80211.h"
#include "wl80211_client.h"
#include "wl80211_scan.h"
#include "wl80211_survey.h"

// max number of vif per radio
#define TARGET_MAX_VIF              3
#define TARGET_WAN_INTERFACE        "eth0"
#define TARGET_ETHCLIENT_IFLIST     "eth0"


#define TARGET_CERT_PATH            "/var/certs"
#define TARGET_MANAGERS_PID_PATH    "/var/run/opensync"
#define TARGET_OVSDB_SOCK_PATH      "/var/run/db.sock"
#define TARGET_LOGREAD_FILENAME     "/var/log/messages"


/******************************************************************************
 *  MANAGERS definitions
 *****************************************************************************/
#if !defined(CONFIG_TARGET_MANAGER)
#define TARGET_MANAGER_PATH(X)      CONFIG_INSTALL_PREFIX"/bin/"X
#endif

/******************************************************************************
 *  CLIENT definitions
 *****************************************************************************/

/******************************************************************************
 *  RADIO definitions
 *****************************************************************************/

/******************************************************************************
 *  VIF definitions
 *****************************************************************************/

/******************************************************************************
 *  SURVEY definitions
 *****************************************************************************/

/******************************************************************************
 *  NEIGHBOR definitions
 *****************************************************************************/

/******************************************************************************
 *  DEVICE definitions
 *****************************************************************************/

/******************************************************************************
 *  CAPACITY definitions
 *****************************************************************************/


typedef wl80211_client_record_t target_client_record_t;

typedef wl80211_survey_record_t target_survey_record_t;

typedef void target_capacity_data_t;

/******************************************************************************
 *  VENDOR definitions
 *****************************************************************************/

#include "target_common.h"

#endif /* TARGET_OS_EXTENDER_BCM52_H_INCLUDED */
