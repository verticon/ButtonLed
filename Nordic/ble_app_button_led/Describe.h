#ifndef DESCRIBE_H__
#define DESCRIBE_H__

#include <ble.h>
#include <ble_advertising.h>

char* DescribeBleStatus(uint8_t status, char* outDescription);

char* DescribeBleEvent(ble_evt_t* pEvent, char* outDescription);

char* DescribeBleAdvEvent(ble_adv_evt_t eventId, char* outBuffer);

#endif
