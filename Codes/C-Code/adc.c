/*
 * 																AUTHORS
 * 															IIT BOMBAY STUDENTS :
 * 
 * 														ARPIT MALANI (10305901)
 * 														HERMESH GUPTA (10305080)
 * 														RAHUL NIHALANI (10305003)
 * 														VIVEK V VELANKAR (10305050)
 * 
 * 														Last Modified : 9 Nov 2010
 */

/* This program is loaded on the firebird and controls the navigation of bot in an unknown arena.
 * It calculates the distance of bot from any obstacle in all 5 directions upto maximum of 80 cms.
 * After calculating the distance, based on all 5 values it makes a decision as to where to move 
 * the bot so that it does not collide with the obstacle and also make sure that the bot covers 
 * as much area of the arena as possible 
 */

#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

#include <math.h> //included to support power function

#include "lcd.c"

#define FCPU 11059200ul //defined here to make sure that program works properly

//definations for different delays
#define DELAY 200
#define MINIDELAY 100
#define ZIGBEEDELAY 10	
#define BIGDELAY 300
#define THRESHOLD 15
#define MINITHRESHOLD 9
#define SHEERTHRESHOLD 6
unsigned char data; //to store received data from UDR0

unsigned char ADC_Conversion(unsigned char);
unsigned char ADC_Value;
unsigned char sharp, distance, adc_reading;
/* contains the sharp values of all 5 sensors*/
unsigned char sharp9,sharp10,sharp11,sharp12,sharp13;
/* contains the proximity values of all 5 sensors*/
unsigned char prox[5];
/* contains the final distance values of all 5 directions*/
unsigned char finalDistance[5];
/* contains the sharp distance values of all 5 sensors calculated from sharp values*/
unsigned int value0, value1, value2, value3, value4;

int counter;

unsigned int MAX=0, MAX_VALUE;
//float BATT_Voltage, BATT_V;
unsigned char WHITE_1,WHITE_2,WHITE_3;

/*Determines the the direction where we have maximum space to move*/
void calculateMax(int,int,int,int,int);

void lcd_port_config (void)
	{
	DDRC = DDRC | 0xF7; 	//all the LCD pin's direction set as output
	PORTC = PORTC & 0x80; 	// all the LCD pins are set to logic 0 except PORTC 7
	}

//ADC pin configuration
void adc_pin_config (void)
	{
	DDRF = 0x00; 
	PORTF = 0x00;
	DDRK = 0x00;
	PORTK = 0x00;
	}

void port_init()
	{
	lcd_port_config();
	adc_pin_config();	
	DDRA=0x0F;
	PORTA=0x00;	
	DDRL=0x18;
	PORTL=0x18;
	}
	
void adc_init()
	{
	ADCSRA = 0x00;
	ADCSRB = 0x00;		//MUX5 = 0
	ADMUX = 0x20;		//Vref=5V external --- ADLAR=1 --- MUX4:0 = 0000
	ACSR = 0x80;
	ADCSRA = 0x86;		//ADEN=1 --- ADIE=1 --- ADPS2:0 = 1 1 0
	}

void init_devices (void)
	{
	//Clears the global interrupts
	cli();
	port_init();
	adc_init();
	XMCRA=0x00;
	XMCRB=0x00;
	uart0_init(); //Initailize UART1 for serial communiaction
	EIMSK  = 0x00;
	TIMSK0 = 0x00; //timer0 interrupt sources
	TIMSK1 = 0x00; //timer1 interrupt sources
	TIMSK2 = 0x00; //timer2 interrupt sources
	TIMSK3 = 0x00; //timer3 interrupt sources
	TIMSK4 = 0x00; //timer4 interrupt sources
	TIMSK5 = 0x00; //timer5 interrupt sources
	//Enables the global interrupts
	sei();
	}
	
unsigned char ADC_Conversion(unsigned char Ch)
	{
	unsigned char a;
	if(Ch>7)
		{
		ADCSRB = 0x08;			// select the ch. > 7
		}
	Ch = Ch & 0x07;  			
	ADMUX= 0x20| Ch;	   		//do not disturb the left adjustment
	ADCSRA = ADCSRA | 0x40;		//Set start conversion bit
	while((ADCSRA&0x10)==0);	//Wait for ADC conversion to complete
	a=ADCH;
	ADCSRA = ADCSRA|0x10; 		//clear ADIF (ADC Interrupt Flag) by writing 1 to it
	ADCSRB = 0x00;
	return a;
	}
	
unsigned int Sharp_GP2D12_estimation(unsigned char adc_reading)
	{
	float distance;
	unsigned int distanceInt;
	distance = (int)(10.00*(2799.6*(1.00/(pow(adc_reading,1.1546)))));
	distanceInt = (int)distance;
	if(distanceInt>800)
		{
		distanceInt=800;
		}
	return distanceInt;
	}

void forward()
{
	PORTA=0x06;
}
void stop()
{
PORTA=0x00;
}
void backward()
{
PORTA=0x09;
}
void softleft()
{PORTA=0x04;
}
void softright()
{PORTA=0x02;
}
void hardleft()
{
	PORTA=0x05;			
}

void hardright()
{
	PORTA=0x0A;			
}

/*Function to calculate distance upto 10 cm from proximity sensor values. We plotted a graph and figured out that a function like the following would give the best values of distance*/
int proximityDistance(int proxVal)
{
	if(proxVal<10)
	{
		return 1;
	}
	if(proxVal<100)
	{
		return 2;
	}
	if(proxVal<180)
	{
		return 3;
	}
	if(proxVal<200)
	{
		return 4;
	}
	if(proxVal<220)
	{
		return 5;
	}
	if(proxVal<230)
	{
		return 6;
	}
	if(proxVal<235)
	{
		return 7;
	}
	if(proxVal<240)
	{
		return 8;
	}
	return 0;
}

/*Calculates the final distance in all 5 directions from the 10 sensor values*/
int final_distance(int sharp_value, int proximity_value, int index)
{
	//lcd_print(1,1,proximity_value,3);
	//lcd_print(1,5,sharp_value,3);
	if (proximity_value>=240)
	{
		return sharp_value;
	}
	else
	{
		return proximityDistance(proximity_value);
	}
}

int main(void)
{
	/*toggle is used to randomize the direction of turn in case needed, change is a general variable*/
	unsigned int value,toggle=1,change=0;
	init_devices();
	lcd_set_4bit();
	lcd_init();
	
	while(1)
	{
		toggle=1-toggle;//randomize the direction of turn
		//_delay_ms(10);
		sharp9 = ADC_Conversion(9);						//Stores the Analog value of front sharp connected to ADC channel 11 into variable "sharp"
		sharp10 = ADC_Conversion(10);
		sharp11 = ADC_Conversion(11);
		sharp12 = ADC_Conversion(12);
		sharp13 = ADC_Conversion(13);
		value0 = Sharp_GP2D12_estimation(sharp9)/10;				//Stores Distance calsulated in a variable "value".
		value1 = Sharp_GP2D12_estimation(sharp10)/10;
		value2 = Sharp_GP2D12_estimation(sharp11)/10;
		value3 = Sharp_GP2D12_estimation(sharp12)/10;
		value4 = Sharp_GP2D12_estimation(sharp13)/10;


		prox[0] = ADC_Conversion(4);						//Stores the Analog value of front sharp connected to ADC channel 11 into variable "sharp"
		prox[1] = ADC_Conversion(5);
		prox[2] = ADC_Conversion(6);
		prox[3] = ADC_Conversion(7);
		prox[4] = ADC_Conversion(8);


		finalDistance[0]=final_distance(value0,prox[0], 0);
		finalDistance[1]=final_distance(value1,prox[1], 1);
		finalDistance[2]=final_distance(value2,prox[2], 2);
		finalDistance[3]=final_distance(value3,prox[3], 3);
		finalDistance[4]=final_distance(value4,prox[4], 4);
		lcd_print(2,1,finalDistance[0], 2);//final distance
		lcd_print(2,4,finalDistance[1],2);
		lcd_print(2,7,finalDistance[2], 2);
		lcd_print(2,10,finalDistance[3],2);
		lcd_print(2,13,finalDistance[4],2);	
		//sending values of distance to xbee
		stop();
		UDR0 = 'a';
		UDR0 = finalDistance[0];
		_delay_ms(ZIGBEEDELAY);
		UDR0='b';
		UDR0 = finalDistance[1];
		_delay_ms(ZIGBEEDELAY);
		UDR0='c';
		UDR0 = finalDistance[2];
		_delay_ms(ZIGBEEDELAY);
		UDR0='d';
		UDR0 = finalDistance[3];;
		_delay_ms(ZIGBEEDELAY);
		UDR0='e';
		UDR0 = finalDistance[4];
		//_delay_ms(500);

/* NOW THE DECISION MAKING STARTS*/

		calculateMax(finalDistance[0],finalDistance[1],finalDistance[2],finalDistance[3],finalDistance[4]);
		
		if(finalDistance[2]>=THRESHOLD) /* Hence there is sufficient space in front */
		{
			lcd_print(1,1,'1'-48,2);
			lcd_print(1,4,MAX,2);
			lcd_print(1,7,MAX_VALUE,2);
			if(finalDistance[1]>=MINITHRESHOLD && finalDistance[3]>=MINITHRESHOLD) /* Moving in front will not create any problem*/
			{
				forward();
				_delay_ms(MINIDELAY);
			}
			else if (toggle==1)	/* Moving in front may lead to collision, toggle is just for randomization*/
			{
				if(finalDistance[2]>MINITHRESHOLD && finalDistance[3]>=MINITHRESHOLD) /* There is a space in the right direction */
				{
					softright();
					_delay_ms(DELAY);
				}
				else if(finalDistance[1]>=MINITHRESHOLD && finalDistance[2]>MINITHRESHOLD) /* There is a space in the left direction */
				{
					softleft();
					_delay_ms(DELAY);
				}
				else /* There is no space forward, need to revert back, and also take a turn so that it is not stuck in a loop*/
				{
					backward();
					_delay_ms(BIGDELAY);
					calculateMax(finalDistance[0],finalDistance[1],0,finalDistance[3],finalDistance[4]);
					if(MAX==0 || MAX==1) /* MAX contains the direction where we have maximum space, we go in that direction*/
					{
						hardleft();
						_delay_ms(MINIDELAY);
					}
					else if(MAX==3 || MAX==4)
					{
						hardright();
						_delay_ms(MINIDELAY);
					}
				}
			}
			else /* Case toggle = 0, refer to previous else statement's comments for clarification*/
			{
				if(finalDistance[1]>=MINITHRESHOLD && finalDistance[2]>MINITHRESHOLD)/*refer to toggle=1 case statement's comments for clarification*/
				{
					softleft();
					_delay_ms(DELAY);
				}
				else if(finalDistance[2]>MINITHRESHOLD && finalDistance[3]>=MINITHRESHOLD) /*refer to toggle=1 case statement's comments for clarification*/
				{
					softright();
					_delay_ms(DELAY);
				}
				else /*refer to toggle=1 case statement's comments for clarification*/
				{
					backward();
					_delay_ms(BIGDELAY);
					calculateMax(finalDistance[0],finalDistance[1],0,finalDistance[3],finalDistance[4]);
					if(MAX==0 || MAX==1)
					{
						hardleft();
						_delay_ms(MINIDELAY);
					}
					else if(MAX==3 || MAX==4)
					{
						hardright();
						_delay_ms(MINIDELAY);
					}
				}
			}

		}
		else /* final_distance[2] < threshold and hence there is no space in forward direction */
		{
			lcd_print(1,1,'2'-48,2);
			lcd_print(1,4,MAX,2);
			lcd_print(1,7,MAX_VALUE,2);
			change=0; /* change will monitor if any decision has been taken in some course of time, refer 51 lines ahead for more clarification*/
			/* Monitoring the left and right values*/
			if((finalDistance[0]<SHEERTHRESHOLD || finalDistance[1]<MINITHRESHOLD) && (finalDistance[3]<MINITHRESHOLD || finalDistance[4]<SHEERTHRESHOLD))
			{
				//stop();
				//_delay_ms(DELAY);
				backward();
				_delay_ms(BIGDELAY);
				calculateMax(finalDistance[0],finalDistance[1],0,finalDistance[3],finalDistance[4]);
				if(MAX==0 || MAX==1)
				{
					hardleft();
					_delay_ms(MINIDELAY);
				}
				else if(MAX==3 || MAX==4)
				{
					hardright();
					_delay_ms(MINIDELAY);
				}
				
			}
			else if (toggle==1) /* toggle for randomization */
			{
				if(finalDistance[1]<MINITHRESHOLD && finalDistance[3]>MINITHRESHOLD && finalDistance[4]>SHEERTHRESHOLD) /* there is little space in right direction, so hardright insted of softright*/ 
				{
					hardright();
					_delay_ms(MINIDELAY);
					change=1;
				}
				else if(finalDistance[3]<MINITHRESHOLD && finalDistance[0]>SHEERTHRESHOLD && finalDistance[1]>MINITHRESHOLD) /* there is little space in right direction, so hardleft insted of softleft*/
				{
					hardleft();
					_delay_ms(MINIDELAY);
					change=1;
				}
			}
			else if (toggle==0) /* refer to prev. toggle=1 case for clarifications*/
			{
				if(finalDistance[3]<MINITHRESHOLD && finalDistance[0]>SHEERTHRESHOLD && finalDistance[1]>MINITHRESHOLD)
				{
					hardleft();
					_delay_ms(MINIDELAY);
					change=1;
				}
				else if(finalDistance[1]<MINITHRESHOLD && finalDistance[3]>MINITHRESHOLD && finalDistance[4]>SHEERTHRESHOLD)
				{
					hardright();
					_delay_ms(MINIDELAY);
					change=1;
				}
			}
			if (change==0) /* i e no decision has been taken, so decision will be taken through this case*/
			{/*if finalDistance[2] < 20 and max !=2 then it gets executed, i e there is no space forward, so bot has to go right, left or back */
				calculateMax(finalDistance[0],finalDistance[1],finalDistance[2],finalDistance[3],finalDistance[4]);
				switch(MAX)
				{
					case 0:
					case 1: /* if there is space in right direction */
						{
							hardleft();
							_delay_ms(MINIDELAY);
							break;
						}
					case 4:
					case 3: /* if there is space in left direction */
						{
							hardright();
							_delay_ms(MINIDELAY);
							break;
						}
					default: /* No space anywhere, go back*/
						{
							backward();
							_delay_ms(DELAY);
						}
				}
			}
		}
	}
}

void uart0_init(void)
{
 UCSR0B = 0x00; //disable while setting baud rate
 UCSR0A = 0x00;
 UCSR0C = 0x06;
 UBRR0L = 0x47; //set baud rate lo
 UBRR0H = 0x00; //set baud rate hi
 UCSR0B = 0x98;
}

SIGNAL(SIG_USART0_RECV) // ISR for receive complete interrupt
{
	data = UDR0; 		//making copy of data from UDR in data variable 
	//UDR0 = finalDistance[1]; 
	//UDR0 = finalDistance[2]; 
	//UDR0 = finalDistance[3]; 
	//UDR0 = finalDistance[4]; 


		/*if(data == '8')
		{
			PORTA=0x06;  //forward
		}

		if(data == '2')
		{
			PORTA=0x09; //back
		}

		if(data == '4')
		{
			PORTA=0x05;  //left
		}

		if(data == '6')
		{
			PORTA=0x0A; //right
		}

		if(data == '5')
		{
			PORTA=0x00; //stop
		}*/

}
 void calculateMax(int d0,int d1,int d2,int d3,int d4)
 {

	    MAX_VALUE=d0;
		MAX=0;
		if (d1>MAX_VALUE)
		{
			MAX=1;
			MAX_VALUE=d1;
		}		
		if (d2>MAX_VALUE)
		{
			MAX=2;
			MAX_VALUE=d2;
		}		
		if (d3>MAX_VALUE)
		{
			MAX=3;
			MAX_VALUE=d3;
		}		
		if (d4>MAX_VALUE)
		{
			MAX=4;
			MAX_VALUE=d4;
		}
 }
