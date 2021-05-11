// ------------------------------------------------------------
// Init function
// ------------------------------------------------------------
int8_t commInit(uint8_t power_level)
{
  int8_t err = 0;
  
  // It connects XBee, activating switch and opens the UART0
  err = xbee802.ON(); 
  #if defined(_DEBUG_COMM_)
    USB.print(F("xbee802.ON() returned: "));
    USB.println(err);
  #endif
  
  // Set transmit power
  err |= xbee802.setPowerLevel(power_level);
  #if defined(_DEBUG_COMM_)
    USB.print(F("xbee802.setPowerLevel() returned: "));
    USB.println(err);
  #endif
  
  // Set RSSI time
  err |= xbee802.setRSSItime(0x05);
  #if defined(_DEBUG_COMM_)
    USB.print(F("xbee802.setRSSItime() returned: "));
    USB.println(err);
  #endif

  // Report
  #if defined(_DEBUG_COMM_)
    USB.print(F("Free Memory after commInit: "));
    USB.println(freeMemory(), DEC);
    USB.println();
  #endif  
  
  return err;
}

// ------------------------------------------------------------
// Shutdown function
// ------------------------------------------------------------
void commShutdown()
{
  #if defined(_DEBUG_COMM_)
    USB.println(F("Executing commShutdown()"));
  #endif  
  
  // This switches off the XBee radio
  xbee802.OFF();
}


// ------------------------------------------------------------
// Send an ASCII packet
// ------------------------------------------------------------
int8_t sendTextPacket(char *destination, char *data)
{
  #if defined(_DEBUG_COMM_)
    USB.println(F("Trying to send a comm packet"));
  #endif
  
  uint8_t error = xbee802.send(destination, data);
 
  if( !error )
  {
    #if defined(_DEBUG_COMM_)
      USB.println();
      USB.println(F("\n\tPacket sent ok"));
    #endif
    blinkLED(GREEN_LED,100);
    return 0;
  }
  else 
  {
    USB.println(F("\n\tTX Error")); 
    if (xbee802.error_RX) USB.println(F("\tRX Error"));
    blinkLED(RED_LED,100);
    return -1;
  }  
}

// ------------------------------------------------------------
// Receive an ASCII packet
// maxWaitTimeMS in milliseconds
// ------------------------------------------------------------
int8_t receiveTextPacket(char *from, char *data, uint32_t maxWaitTimeMS)
{
  #if defined(_DEBUG_COMM_)
    USB.println("\nAwaiting comm packet");
  #endif

  // receive XBee packet (wait for 10 seconds)
  int8_t error = xbee802.receivePacketTimeout( maxWaitTimeMS );

  // check answer  
  if( error == 0 ) 
  { 
    snprintf(from,17,"%02X%02X%02X%02X%02X%02X%02X%02X",
             xbee802._srcMAC[0],xbee802._srcMAC[1],xbee802._srcMAC[2],xbee802._srcMAC[3],
             xbee802._srcMAC[4],xbee802._srcMAC[5],xbee802._srcMAC[6],xbee802._srcMAC[7]);
			 
	snprintf(data, xbee802._length+1, "%s", xbee802._payload);
             
    // Show data stored in '_payload' buffer indicated by '_length'
    USB.println(F("\n------------- Packet received -------------"));
    USB.printf("Data (%d bytes): ",xbee802._length);  
    USB.println( xbee802._payload, xbee802._length);
    USB.printf("rssi: %d dBm\n", xbee802._rssi);
          
    // Packet received OK: don't wait any longer
    blinkLED(GREEN_LED, 150);
  }
  else
  {
    // Print error message:
    /*
     * '7' : Buffer full. Not enough memory space
     * '6' : Error escaping character within payload bytes
     * '5' : Error escaping character in checksum byte
     * '4' : Checksum is not correct   
     * '3' : Checksum byte is not available 
     * '2' : Frame Type is not valid
     * '1' : Timeout when receiving answer   
    */
    #if defined(_DEBUG_COMM_)
      USB.print(F("Error receiving a packet:"));
      USB.println(error,DEC);    
    #endif
    
    // Packet was received with error
    blinkLED(RED_LED, 150); 
  }
  return error;
}

// ------------------------------------------------------------
// Utility function for composing MAC address as string
// ------------------------------------------------------------
void mac2char(char mac[17], Node * ptr)
{
  snprintf(mac,17,"%02X%02X%02X%02X%02X%02X%02X%02X",
                    ptr->SH[0],
                    ptr->SH[1],
                    ptr->SH[2],
                    ptr->SH[3],
                    ptr->SL[0],
                    ptr->SL[1],
                    ptr->SL[2],
                    ptr->SL[3]);
}

