#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include "ButtonLedService.h"
#include "ble_srv_common.h"
#include "app_error.h"
#include "SEGGER_RTT.h"

static void buttonHandler(ButtonLedService_t* pService)
{
    if (pService != NULL && pService->connectionHandle != BLE_CONN_HANDLE_INVALID && pService->buttonNotificationsEnabled)
		{
				ble_gatts_hvx_params_t params;
				memset(&params, 0, sizeof(params));

				ble_gatts_value_t currentValue;
				sd_ble_gatts_value_get(pService->connectionHandle, pService->buttonCharacteristicHandles.value_handle, &currentValue);

				// Advance the value from 1 to 10 and then back to 1, repeat. The current value never changes????
				uint8_t newValue = 0;
				//newValue = (currentValue.len == 1 && *currentValue.p_value < 10) ? *currentValue.p_value : 0;
				newValue++;

				uint16_t length = sizeof(newValue);
				
				params.handle = pService->buttonCharacteristicHandles.value_handle;
				params.p_data = &newValue;
				params.p_len  = &length;
				params.type   = BLE_GATT_HVX_NOTIFICATION;

				uint32_t status = sd_ble_gatts_hvx(pService->connectionHandle, &params);
				switch (status)
				{
					case NRF_SUCCESS:
						SEGGER_RTT_printf(0, "The button notification was successfully sent\n");
						break;
					default:
						SEGGER_RTT_printf(0, "The button notification could not be sent; error = %d\n", status);
						break;
				}
		}
}
/*
 * If a connectted device has written to the LED characteristic
 * then use the value to set the state of the actual LED.
 */
static void onBleWrite(ButtonLedService_t* pService, ble_evt_t* pEvent)
{
    ble_gatts_evt_write_t* pWriteEvent = &pEvent->evt.gatts_evt.params.write;
    
    if (pWriteEvent->handle == pService->ledCharacteristicHandles.value_handle)
    {
			SEGGER_RTT_printf(0, "%d bytes were written to the LED characteristic's value; data[0] = %d\n", pWriteEvent->len, pWriteEvent->data[0]); 
      if (pService->ledHandler != NULL)
			{
				bool newLedState = (pWriteEvent->data[0] & 1) != 0;
				pService->ledHandler(newLedState);
			}
    }
    else if (pWriteEvent->handle == pService->buttonCharacteristicHandles.cccd_handle && pWriteEvent->len == 2)
    {
			pService->buttonNotificationsEnabled = ble_srv_is_notification_enabled(pWriteEvent->data);
			SEGGER_RTT_printf(0, "Button notifications were %s\n", pService->buttonNotificationsEnabled ? "Enabled" : "Disabled"); 
    }
}


static void onBleEvent(ButtonLedService_t* pService, ble_evt_t* pEvent)
{
    switch (pEvent->header.evt_id)
    {
        case BLE_GAP_EVT_CONNECTED:
						pService->connectionHandle = pEvent->evt.gap_evt.conn_handle;
            break;
            
        case BLE_GAP_EVT_DISCONNECTED:
						pService->connectionHandle = BLE_CONN_HANDLE_INVALID;
            break;
            
        case BLE_GATTS_EVT_WRITE:
            onBleWrite(pService, pEvent);
            break;
            
        default:
            break;
    }
}


static uint32_t addButtonCharacteristic(ButtonLedService_t* pService)
{
    ble_gatts_attr_md_t cccd;
    memset(&cccd, 0, sizeof(cccd));
    BLE_GAP_CONN_SEC_MODE_SET_OPEN(&cccd.read_perm);
    BLE_GAP_CONN_SEC_MODE_SET_OPEN(&cccd.write_perm);
    cccd.vloc = BLE_GATTS_VLOC_STACK;
    
    ble_gatts_char_md_t configuration;
    memset(&configuration, 0, sizeof(configuration));
		uint8_t description[] = "Button";
    configuration.p_char_user_desc  = description;
		configuration.char_user_desc_size = sizeof(description);
		configuration.char_user_desc_max_size = sizeof(description);
    configuration.p_user_desc_md    = NULL;
    configuration.char_props.read   = 1;
    configuration.char_props.notify = 1;
		pService->buttonNotificationsEnabled = false;
    configuration.p_char_pf         = NULL;
    configuration.p_cccd_md         = &cccd;
    configuration.p_sccd_md         = NULL;
    
    ble_uuid_t uuid;
    uuid.type = pService->uuid.type;
    uuid.uuid = BUTTON_CHARACTERISTIC_UUID;
    
    ble_gatts_attr_md_t metadata;
    memset(&metadata, 0, sizeof(metadata));
    BLE_GAP_CONN_SEC_MODE_SET_OPEN(&metadata.read_perm);
    BLE_GAP_CONN_SEC_MODE_SET_NO_ACCESS(&metadata.write_perm);
    metadata.vloc       = BLE_GATTS_VLOC_STACK;
    metadata.rd_auth    = 0;
    metadata.wr_auth    = 0;
    metadata.vlen       = 0;
    
    ble_gatts_attr_t characteristic;
    memset(&characteristic, 0, sizeof(characteristic));
    characteristic.p_uuid       = &uuid;
    characteristic.p_attr_md    = &metadata;
    characteristic.init_len     = sizeof(uint8_t);
    characteristic.init_offs    = 0;
    characteristic.max_len      = sizeof(uint8_t);
    characteristic.p_value      = NULL;
    
    return sd_ble_gatts_characteristic_add(pService->connectionHandle, &configuration, &characteristic, &pService->buttonCharacteristicHandles);
}

static uint32_t addLedCharacteristic(ButtonLedService_t* pService)
{
    ble_gatts_char_md_t configuration;
    memset(&configuration, 0, sizeof(configuration));
		uint8_t description[] = "LED";
    configuration.p_char_user_desc  = description;
		configuration.char_user_desc_size = sizeof(description);
		configuration.char_user_desc_max_size = sizeof(description);
    configuration.p_user_desc_md    = NULL;
    configuration.char_props.read   = 1;
    configuration.char_props.write  = 1;
    configuration.p_char_pf         = NULL;
    configuration.p_cccd_md         = NULL;
    configuration.p_sccd_md         = NULL;
    
    ble_uuid_t uuid;
    uuid.type = pService->uuid.type;
    uuid.uuid = LED_CHARACTERISTIC_UUID;
    
    ble_gatts_attr_md_t metadata;
    memset(&metadata, 0, sizeof(metadata));
    BLE_GAP_CONN_SEC_MODE_SET_OPEN(&metadata.read_perm);
    BLE_GAP_CONN_SEC_MODE_SET_OPEN(&metadata.write_perm);
    metadata.vloc       = BLE_GATTS_VLOC_STACK;
    metadata.rd_auth    = 0;
    metadata.wr_auth    = 0;
    metadata.vlen       = 0; // Is the length of the characteristic's value variable?
    
    ble_gatts_attr_t characteristic;
    memset(&characteristic, 0, sizeof(characteristic));
    characteristic.p_uuid       = &uuid;
    characteristic.p_attr_md    = &metadata;
    characteristic.init_len     = sizeof(uint8_t);
    characteristic.init_offs    = 0;
    characteristic.max_len      = sizeof(uint8_t);
    characteristic.p_value      = NULL;
    
    return sd_ble_gatts_characteristic_add(pService->connectionHandle, &configuration, &characteristic, &pService->ledCharacteristicHandles);
}

ButtonLedService_t* createButtonLedService(void (*ledHandler) (bool))
{
    uint32_t   err_code; // Variable to hold return codes from library and softdevice functions
		ButtonLedService_t*	pService = (ButtonLedService_t*) malloc(sizeof(ButtonLedService_t));
    
    // Declare 16 bit service and 128 bit base UUIDs and add them to BLE stack table     
		pService->uuid.uuid = SERVICE_UUID;
		ble_uuid128_t base_uuid = BASE_UUID;
		err_code = sd_ble_uuid_vs_add(&base_uuid, &pService->uuid.type);
		APP_ERROR_CHECK(err_code);
	
    // Add service
		err_code = sd_ble_gatts_service_add(BLE_GATTS_SRVC_TYPE_PRIMARY, &pService->uuid, &pService->connectionHandle);
		APP_ERROR_CHECK(err_code);
	
		pService->onBleEvent = onBleEvent;
	
		addButtonCharacteristic(pService);
		pService->buttonHandler = buttonHandler;

		addLedCharacteristic(pService);
		pService->ledHandler = ledHandler;
	
		return pService;
}
