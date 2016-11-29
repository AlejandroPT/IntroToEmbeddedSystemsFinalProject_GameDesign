// ADC.c
// Runs on LM4F120/TM4C123
// Provide functions that initialize ADC0
// Last Modified: 3/6/2015 
// Student names: change this to your names or look very silly
// Last modification date: change this to the last modification date or look very silly

#include <stdint.h>
#include "tm4c123gh6pm.h"

// ADC initialization function 
// Input: none
// Output: none
void ADC_Init(void){ 
	volatile unsigned long delay;
	SYSCTL_RCGCGPIO_R |= 0x30;      // 1) activate clock for Port E and F
  while((SYSCTL_PRGPIO_R&0x10) == 0){};
  GPIO_PORTE_DIR_R &= ~0x10;      // 2) make PE4 input
  GPIO_PORTE_AFSEL_R |= 0x10;     // 3) enable alternate fun on PE4
  GPIO_PORTE_DEN_R &= ~0x10;      // 4) disable digital I/O on PE4 because it now analog 
  GPIO_PORTE_AMSEL_R |= 0x10;     // 5) enable analog fun on PE4
  SYSCTL_RCGCADC_R |= 0x01;       // 6) turn on clock for the ADC0 
  delay = SYSCTL_RCGCADC_R;       // extra time to stabilize
  delay = SYSCTL_RCGCADC_R;       // extra time to stabilize
  delay = SYSCTL_RCGCADC_R;       // extra time to stabilize
  delay = SYSCTL_RCGCADC_R;
  ADC0_PC_R = 0x01;               // 7) sampling rate = 125K 
  ADC0_SSPRI_R = 0x0123;          // 8) Seq 3 is highest priority
  ADC0_ACTSS_R &= ~0x0008;        // 9) disable sample sequencer 3
  ADC0_EMUX_R &= ~0xF000;         // 10) seq3 is software trigger
  ADC0_SSMUX3_R = (ADC0_SSMUX3_R&0xFFFFFFF0)+9;  // 11) Ain9 (PE4)
  ADC0_SSCTL3_R = 0x0006;         // 12) no TS0 D0, yes IE0 END0
  ADC0_IM_R &= ~0x0008;           // 13) disable SS3 interrupts
  ADC0_ACTSS_R |= 0x0008;         // 14) enable sample sequencer 3
}

//------------ADC_In------------
// Busy-wait Analog to digital conversion
// Input: none
// Output: 12-bit result of ADC conversion
uint32_t ADC_In(void){  
	unsigned long result;
	ADC0_PSSI_R = 0x0008;            // 1) initiate SS3
  while((ADC0_RIS_R&0x08)==0){};   // 2) wait for conversion done by checking status bit
  result = ADC0_SSFIFO3_R&0xFFF;   // 3) read result in the FIFO3
  ADC0_ISC_R = 0x0008;             // 4) acknowledge completion by clearing the bit
  return result;
}
//uint32_t test;

//uint32_t button1(void){
//	GPIO_PORTF_DATA_R ^= 0x04;
//	GPIO_PORTF_DATA_R ^= 0x04;
//	GPIO_PORTF_DATA_R ^= 0x04;
//	GPIO_PORTF_DATA_R ^= 0x04;
//	test= (GPIO_PORTF_DATA_R&0x10);
//	uint32_t testjnkq=test;
//	GPIO_PORTF_DATA_R ^= 0x04;
//	return (GPIO_PORTF_DATA_R&0x10);
//}

