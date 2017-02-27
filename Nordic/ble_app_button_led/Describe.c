#include <ble_hci.h>
#include <stdio.h>

#include "Describe.h"

char* DescribeBleStatus(uint8_t status, char* outDescription)
{
	switch (status)
	{
    case BLE_HCI_STATUS_CODE_SUCCESS:
			sprintf(outDescription, "Success");
			break;
    case BLE_HCI_STATUS_CODE_UNKNOWN_BTLE_COMMAND:
			sprintf(outDescription, "Unknown BLE Command");
			break;
    case BLE_HCI_STATUS_CODE_UNKNOWN_CONNECTION_IDENTIFIER:
			sprintf(outDescription, "Unknown Connection Identifier");
			break;
    case BLE_HCI_AUTHENTICATION_FAILURE:
			sprintf(outDescription, "Authentication Failure");
			break;
    case BLE_HCI_STATUS_CODE_PIN_OR_KEY_MISSING:
			sprintf(outDescription, "Pin or Key missing");
			break;
    case BLE_HCI_MEMORY_CAPACITY_EXCEEDED:
			sprintf(outDescription, "Memory Capacity Exceeded");
			break;
    case BLE_HCI_CONNECTION_TIMEOUT:
			sprintf(outDescription, "Connection Timeout");
			break;
    case BLE_HCI_STATUS_CODE_COMMAND_DISALLOWED:
			sprintf(outDescription, "Command Disallowed");
			break;
    case BLE_HCI_STATUS_CODE_INVALID_BTLE_COMMAND_PARAMETERS:
			sprintf(outDescription, "Invalid BLE Command Parameters");
			break;
    case BLE_HCI_REMOTE_USER_TERMINATED_CONNECTION:
			sprintf(outDescription, "Remote User Terminated Connection");
			break;
    case BLE_HCI_REMOTE_DEV_TERMINATION_DUE_TO_LOW_RESOURCES:
			sprintf(outDescription, "Remote Device Terminated Connection due to low resources");
			break;
    case BLE_HCI_REMOTE_DEV_TERMINATION_DUE_TO_POWER_OFF:
			sprintf(outDescription, "Remote Device Terminated Connection due to power off");
			break;
    case BLE_HCI_LOCAL_HOST_TERMINATED_CONNECTION:
			sprintf(outDescription, "Local Host Terminated Connection");
			break;
    case BLE_HCI_UNSUPPORTED_REMOTE_FEATURE:
			sprintf(outDescription, "Unsupported Remote Feature");
			break;
    case BLE_HCI_STATUS_CODE_INVALID_LMP_PARAMETERS:
			sprintf(outDescription, "Invalid LMP Parameters");
			break;
    case BLE_HCI_STATUS_CODE_UNSPECIFIED_ERROR:
			sprintf(outDescription, "Unspecified Error");
			break;
    case BLE_HCI_STATUS_CODE_LMP_RESPONSE_TIMEOUT:
			sprintf(outDescription, "LMP Response Timeout");
			break;
    case BLE_HCI_STATUS_CODE_LMP_PDU_NOT_ALLOWED:
			sprintf(outDescription, "LMP PDU Not Allowed");
			break;
    case BLE_HCI_INSTANT_PASSED:
			sprintf(outDescription, "Instant Passed");
			break;
    case BLE_HCI_PAIRING_WITH_UNIT_KEY_UNSUPPORTED:
			sprintf(outDescription, "Pairing with Unit Key Unsupported");
			break;
    case BLE_HCI_DIFFERENT_TRANSACTION_COLLISION:
			sprintf(outDescription, "Different Transaction Collision");
			break;
    case BLE_HCI_CONTROLLER_BUSY:
			sprintf(outDescription, "Controller Busy");
			break;
    case BLE_HCI_CONN_INTERVAL_UNACCEPTABLE:
			sprintf(outDescription, "Connection Interval Unacceptable");
			break;
    case BLE_HCI_DIRECTED_ADVERTISER_TIMEOUT:
			sprintf(outDescription, "Directed Adverisement Timeout");
			break;
    case BLE_HCI_CONN_TERMINATED_DUE_TO_MIC_FAILURE:
			sprintf(outDescription, "Connection Terminated due to MIC Failure");
			break;
    case BLE_HCI_CONN_FAILED_TO_BE_ESTABLISHED:
			sprintf(outDescription, "Connection Failed to be Established");
			break;
		default:
			sprintf(outDescription, "Unknown status(value = 0x%02x)", status);
			break;
	}
	return outDescription;
}

char* DescribeBleEvent(ble_evt_t* pEvent, char* outDescription)
{
	ble_common_evt_t* pCommonEvent =	(ble_common_evt_t*)(&pEvent->evt);	/**< Common Event, evt_id in BLE_EVT_* series. */
	ble_gap_evt_t* 		pGapEvent = 		(ble_gap_evt_t*)(&pEvent->evt); 		/**< GAP originated event, evt_id in BLE_GAP_EVT_* series. */
	//ble_l2cap_evt_t* 	pL2capEvent = 	(ble_l2cap_evt_t*)(&pEvent->evt); 	/**< L2CAP originated event, evt_id in BLE_L2CAP_EVT* series. */
	//ble_gattc_evt_t* 	pGattcEvent = 	(ble_gattc_evt_t*)(&pEvent->evt); 	/**< GATT client originated event, evt_id in BLE_GATTC_EVT* series. */
	//ble_gatts_evt_t* 	pGattsEvent = 	(ble_gatts_evt_t*)(&pEvent->evt); 	/**< GATT server originated event, evt_id in BLE_GATTS_EVT* series. */

	switch(pEvent->header.evt_id)
	{
		/* Common events */
		case BLE_EVT_TX_COMPLETE:
			{
				ble_evt_tx_complete_t* pParams = (ble_evt_tx_complete_t*)(&pCommonEvent->params);
				sprintf(outDescription, "%d packets transmitted on connection 0x%02x", pParams->count, pCommonEvent->conn_handle);
			}
			break;
		case BLE_EVT_USER_MEM_REQUEST:
			{
				//ble_evt_user_mem_request_t*	pParams = (ble_evt_user_mem_request_t*)(&pCommonEvent->params);
				sprintf(outDescription, "User memory request on connection 0x%02x", pCommonEvent->conn_handle);
			}
			break;
		case BLE_EVT_USER_MEM_RELEASE:
			{
				//ble_evt_user_mem_release_t*	pParams = (ble_evt_user_mem_release_t*)(&pCommonEvent->params);
				sprintf(outDescription, "User memory release on connection 0x%02x", pCommonEvent->conn_handle);
			}
		break;

			/* GAP events */
		case BLE_GAP_EVT_CONNECTED:
			{
				//ble_gap_evt_connected_t* pParams = &pGapEvent->params.connected;
				sprintf(outDescription, "Connection established");
			}
			break;
		case BLE_GAP_EVT_DISCONNECTED:
			{
				ble_gap_evt_disconnected_t* pParams = &pGapEvent->params.disconnected;
				char reason[100];
				DescribeBleStatus(pParams->reason, reason);
				sprintf(outDescription, "Disconnected from peer: %s", reason);
			}
			break;
		case BLE_GAP_EVT_CONN_PARAM_UPDATE:
			{
				//ble_gap_evt_conn_param_update_t* pParams = &pGapEvent->params.conn_param_update;
				sprintf(outDescription, "Connection parameter updated");
			}
			break;
		case BLE_GAP_EVT_SEC_PARAMS_REQUEST:
			{
				//ble_gap_evt_sec_params_request_t* pParams = &pGapEvent->params.sec_params_request;
				sprintf(outDescription, "Security parameters requested");
			}
			break;
		case BLE_GAP_EVT_SEC_INFO_REQUEST:
			{
				//ble_gap_evt_sec_info_request_t* pParams = &pGapEvent->params.sec_info_request;
				sprintf(outDescription, "Security information requested");
			}
			break;
		case BLE_GAP_EVT_PASSKEY_DISPLAY:
			{
				//ble_gap_evt_passkey_display_t* pParams = &pGapEvent->params.passkey_display;
				sprintf(outDescription, "Display passkey to user requested");
			}
			break;
		case BLE_GAP_EVT_AUTH_KEY_REQUEST:
			{
				//ble_gap_evt_auth_key_request_t* pParams = &pGapEvent->params.auth_key_request;
				sprintf(outDescription, "Authentication key requested");
			}
			break;
		case BLE_GAP_EVT_AUTH_STATUS:
			{
				//ble_gap_evt_auth_status_t* pParams = &pGapEvent->params.auth_status;
				sprintf(outDescription, "Authentication status report");
			}
			break;
		case BLE_GAP_EVT_CONN_SEC_UPDATE:
			{
				//ble_gap_evt_conn_sec_update_t* pParams = &pGapEvent->params.conn_sec_update;
				sprintf(outDescription, "Connection security updated");
			}
			break;
		case BLE_GAP_EVT_TIMEOUT:
			{
				//ble_gap_evt_timeout_t* pParams = &pGapEvent->params.timeout;
				sprintf(outDescription, "Timeout expired");
			}
			break;
		case BLE_GAP_EVT_RSSI_CHANGED:
			{
				//ble_gap_evt_rssi_changed_t* pParams = &pGapEvent->params.rssi_changed;
				sprintf(outDescription, "RSSI change report");
			}
			break;
		case BLE_GAP_EVT_ADV_REPORT:
			{
				//ble_gap_evt_adv_report_t* pParams = &pGapEvent->params.adv_report;
				sprintf(outDescription, "Advertising report");
			}
			break;
		case BLE_GAP_EVT_SEC_REQUEST:
			{
				//ble_gap_evt_sec_request_t* pParams = &pGapEvent->params.sec_request;
				sprintf(outDescription, "Security request");
			}
			break;
		case BLE_GAP_EVT_CONN_PARAM_UPDATE_REQUEST:
			{
				//ble_gap_evt_conn_param_update_request_t* pParams = &pGapEvent->params.conn_param_update_request;
				sprintf(outDescription, "Connection parameter update request");
			}
			break;
		case BLE_GAP_EVT_SCAN_REQ_REPORT:
			{
				//ble_gap_evt_scan_req_report_t* pParams = &pGapEvent->params.scan_req_report;
				sprintf(outDescription, "Scan request report");
			}
			break;


		/* L2Cap Events */
		case BLE_L2CAP_EVT_RX:
			{
				//ble_l2cap_evt_rx_t* pParams = &pL2capEvent->params.rx;
				sprintf(outDescription, "Scan request report");
			}
			break;


		/* GattC Events */
		case BLE_GATTC_EVT_PRIM_SRVC_DISC_RSP:
			{
				//ble_gattc_evt_prim_srvc_disc_rsp_t* pParams = &pGattcEvent->params.prim_srvc_disc_rsp;
				sprintf(outDescription, "Primary Service Discovery Response");
			}
			break;
		case BLE_GATTC_EVT_REL_DISC_RSP:
			{
				//ble_gattc_evt_rel_disc_rsp_t* pParams = &pGattcEvent->params.rel_disc_rsp;
				sprintf(outDescription, "Relationship Discovery Response");
			}
			break;
  	case BLE_GATTC_EVT_CHAR_DISC_RSP:
			{
				//ble_gattc_evt_char_disc_rsp_t* pParams = &pGattcEvent->params.char_disc_rsp;
				sprintf(outDescription, "Characteristic Discovery Response");
			}
			break;
  	case BLE_GATTC_EVT_DESC_DISC_RSP:
			{
				//ble_gattc_evt_desc_disc_rsp_t* pParams = &pGattcEvent->params.desc_disc_rsp;
				sprintf(outDescription, "Descriptor Discovery Response");
			}
			break;
  	case BLE_GATTC_EVT_CHAR_VAL_BY_UUID_READ_RSP:
			{
				//ble_gattc_evt_char_val_by_uuid_read_rsp_t* pParams = &pGattcEvent->params.char_val_by_uuid_read_rsp;
				sprintf(outDescription, "Read By UUID Response");
			}
			break;
  	case BLE_GATTC_EVT_READ_RSP:
			{
				//ble_gattc_evt_read_rsp_t* pParams = &pGattcEvent->params.read_rsp;
				sprintf(outDescription, "Read Response");
			}
			break;
  	case BLE_GATTC_EVT_CHAR_VALS_READ_RSP:
			{
				//ble_gattc_evt_char_vals_read_rsp_t* pParams = &pGattcEvent->params.char_vals_read_rsp;
				sprintf(outDescription, "Read multiple Response");
			}
			break;
  	case BLE_GATTC_EVT_WRITE_RSP:
			{
				//ble_gattc_evt_write_rsp_t* pParams = &pGattcEvent->params.write_rsp;
				sprintf(outDescription, "Write Response");
			}
			break;
  	case BLE_GATTC_EVT_HVX:
			{
				//ble_gattc_evt_hvx_t* pParams = &pGattcEvent->params.hvx;
				sprintf(outDescription, "Handle Value Notification or Indication");
			}
			break;
  	case BLE_GATTC_EVT_TIMEOUT:
			{
				//ble_gattc_evt_timeout_t* pParams = &pGattcEvent->params.timeout;
				sprintf(outDescription, "Timeout");
			}
			break;


		/* GattS Events */
  	case BLE_GATTS_EVT_WRITE:
			{
				//ble_gatts_evt_write_t* pParams = &pGattsEvent->params.write;
				sprintf(outDescription, "Write operation performed");
			}
			break;
  	case BLE_GATTS_EVT_RW_AUTHORIZE_REQUEST:
			{
				//ble_gatts_evt_rw_authorize_request_t* pParams = &pGattsEvent->params.authorize_request;
				sprintf(outDescription, "Read/Write authorization request");
			}
			break;
  	case BLE_GATTS_EVT_SYS_ATTR_MISSING:
			{
				///ble_gatts_evt_sys_attr_missing_t* pParams = &pGattsEvent->params.sys_attr_missing;
				sprintf(outDescription, "System attribute missing");
			}
			break;
  	case BLE_GATTS_EVT_HVC:
			{
				//ble_gatts_evt_hvc_t* pParams = &pGattsEvent->params.hvc;
				sprintf(outDescription, "Handle value confirmation");
			}
			break;
  	case BLE_GATTS_EVT_SC_CONFIRM:
			{
				sprintf(outDescription, "Service changed confirmation");
			}
			break;
  	case BLE_GATTS_EVT_TIMEOUT:
			{
				//ble_gatts_evt_timeout_t* pParams = &pGattsEvent->params.timeout;
				sprintf(outDescription, "Timeout");
			}
			break;


		default:
			sprintf(outDescription, "Unknown Event(ID = 0x%02x)", pEvent->header.evt_id);
			break;
	}

	return outDescription;
}

char* DescribeBleAdvEvent(ble_adv_evt_t eventId, char* outBuffer)
{
	switch(eventId)
	{
			case BLE_ADV_EVT_FAST:
				sprintf(outBuffer, "Fast");
				break;
			case BLE_ADV_EVT_IDLE:
				sprintf(outBuffer, "Idle");
				break;
			default:
				sprintf(outBuffer, "Unknown(value = %d)", eventId);
				break;
	}
	return outBuffer;
}

