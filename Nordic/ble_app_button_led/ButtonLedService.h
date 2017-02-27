#ifndef SERVICE_H__
#define SERVICE_H__

#include <stdint.h>
#include "ble.h"
#include "ble_srv_common.h"

#define BASE_UUID             			{{0x23, 0xD1, 0x13, 0xEF, 0x5F, 0x78, 0x23, 0x15, 0xDE, 0xEF, 0x12, 0x12, 0x00, 0x00, 0xBA, 0xDC}} // 128-bit base UUID
#define SERVICE_UUID             		0x3154
#define LED_CHARACTERISTIC_UUID			0x1523
#define BUTTON_CHARACTERISTIC_UUID	0x1524

typedef struct ButtonLedService
{
		ble_uuid_t  								uuid;
    uint16_t    								connectionHandle;

		void 												(*onBleEvent)(struct ButtonLedService*, ble_evt_t*); /* Call into service when the application receives a BLE event */

		ble_gatts_char_handles_t    ledCharacteristicHandles;
		void 												(*ledHandler)(bool); /* Callback from service when service receives a new value for the LED characteristic */

		ble_gatts_char_handles_t    buttonCharacteristicHandles;
		bool												buttonNotificationsEnabled;
		void		 										(*buttonHandler)(struct ButtonLedService*); /* Callback into service when the application detects a button push */
}
ButtonLedService_t;

ButtonLedService_t* createButtonLedService(void (*)(bool));

#endif
