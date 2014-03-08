#define F_CPU 1000000  // CPU frequency for proper time calculation in delay function

#include <avr/io.h>
#include <util/delay.h>

#define dataCmdPin PD4
#define resetPin PD3
#define csPin PD2
#define clkPin PD1
#define dataPin PD0

#define setOutput(ddr, pin) ((ddr) |= (1<< (pin)))
#define setInput(ddr, pin) ((ddr) &= ~(1<< (pin)))
#define setLow(port, pin) ((port) &= ~(1 << (pin)))
#define setHigh(port, pin) ((port) |= (1 << (pin)))
#define outputState(port, pin) ((port) & (1 << (pin)))

unsigned char palette[64] = {0x00, 0x2F, 0x4F, 0x6F, 0x8F, 0xAF, 0xCF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x2F, 0x4F, 0x6F, 0x8F, 0xAF, 0xCF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x55, 0xAA, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF};
int totalCount;

void lcd_sendByte( unsigned char data )
{
	unsigned char mask;
	for ( mask = 128; mask != 0; mask >>= 1 )
	{
		setLow(PORTD, clkPin);
		if ( data & mask )
		{
			setHigh(PORTD, dataPin);
		}
		else
		{
			setLow(PORTD, dataPin);
		}
		setHigh(PORTD, clkPin);
	}
	setLow(PORTD, clkPin);
}

void lcd_sendCommand( unsigned char cmd )
{
	setHigh(PORTD, csPin);
	setLow(PORTD, dataCmdPin);
	setLow(PORTD, csPin);
	lcd_sendByte(cmd);
}

void lcd_sendData( unsigned char cmd )
{
	setHigh(PORTD, dataCmdPin);
	lcd_sendByte(cmd);
}

void lcd_sendDataArray( unsigned char *data, unsigned char count )
{
	unsigned char i;
	for( i = 0; i < count; i++ )
	{
		lcd_sendData( data[i] );
	}
}

void lcd_writeBlock(unsigned char x0, unsigned char y0, unsigned char x1, unsigned char y1, unsigned short count, unsigned char color )
{
	lcd_sendCommand(0x2A);
	lcd_sendData(x0);
	lcd_sendData(x1);
	lcd_sendCommand(0x2B);
	lcd_sendData(y0);
	lcd_sendData(y1);
	lcd_sendCommand(0x2C);
	unsigned short i;
	for ( i = 0; i < count; i++ )
	{
		lcd_sendData( color );
	}
}

void lcd_clearScreen()
{
	lcd_writeBlock(0, 0, 131, 175, 23232, 0x00);
}

void lcd_fillRect(unsigned char x0, unsigned char y0, unsigned char x1, unsigned char y1, unsigned char color )
{
	lcd_writeBlock(x0, y0, x1, y1, (x1-x0+1)*(y1-y0+1), color);
}

void lcd_init()
{
	setHigh(PORTD, csPin);
	setHigh(PORTD, resetPin);
	setLow(PORTD, dataCmdPin);
	setLow(PORTD, dataPin);
	setLow(PORTD, clkPin);

	setLow(PORTD, resetPin);
	_delay_ms(200);
	setHigh(PORTD, resetPin);
	_delay_ms(200);

	setHigh(PORTD, csPin);
	_delay_ms(1);
	setLow(PORTD, csPin);

	lcd_sendCommand(0x01);
	_delay_ms(200);

	lcd_sendCommand(0x36);
	lcd_sendData(0x00);

	lcd_sendCommand(0x2D);
	lcd_sendDataArray( &palette[0], 64 );

	lcd_sendCommand(0x11);
	_delay_ms(20);

	lcd_sendCommand(0x3A);
	lcd_sendData(0x52);
	_delay_ms(20);

	lcd_clearScreen();
	lcd_sendCommand(0x29);
}

void init_io()
{
	//display
	setOutput(DDRD, dataCmdPin);
	setOutput(DDRD, resetPin);
	setOutput(DDRD, csPin);
	setOutput(DDRD, clkPin);
	setOutput(DDRD, dataPin);
	//keyboard rows
	setOutput(DDRB, PB0);
	setOutput(DDRB, PB1);
	setOutput(DDRB, PB2);
	setOutput(DDRB, PB3);
	setOutput(DDRB, PB4);
	setLow(PORTB, PB0);
	setLow(PORTB, PB1);
	setLow(PORTB, PB2);
	setLow(PORTB, PB3);
	setLow(PORTB, PB4);
	//keyboard columns
	setInput(DDRA, PA0);
	setInput(DDRA, PA1);
	setInput(DDRB, PB5);
	setHigh(PORTA, PA0);
	setHigh(PORTA, PA1);
	setHigh(PORTB, PB5);
}

unsigned short get_keyboard_state()
{
/*	unsigned short state = 0;
	unsigned char count = 0;
	unsigned short mask = 1;
	unsigned char submask;
	unsigned char fuck;
	unsigned char column;
	for (column = 0; column < 3; column++)
	{
		setOutput(DDRA, column);
		setLow(PORTA, column);
		fuck = PINB;
		for (submask = 0; submask < 8; submask++)
		{
			if (fuck & 1)
			{
				lcd_fillRect(30 + (submask << 3), 30 + (column << 3), 38 + (submask << 3), 38 + (column << 3), 0x03); 
			}
			else
			{
				lcd_fillRect(30 + (submask << 3), 30 + (column << 3), 38 + (submask << 3), 38 + (column << 3), 0xE0);
			}
			fuck >>= 1;
		}*/
/*		for (submask = 0x8; submask != 0x00; submask <<= 1)
		{
			if (fuck | (~submask))
			{
				count++;
				if (count > 1)
				{
					flash_led_bad();
				}
				else
				{
					flash_led_good();
					state |= mask;
				}
			}
			mask <<= 1;
		}*/
/*		setInput(DDRA, column);
		setHigh(PORTA, column);
	}
	lcd_fillRect(40, 40 + totalCount, 40, 40 + totalCount, 0xFF);
	totalCount++;
	return state;*/

	unsigned char col1 = PINA;
	unsigned char col2 = PINB;
	unsigned char column = 20;
	unsigned char row = 20;
	if ((col1 & 1) != 1)
	{
		column = 0;
	}
	else if ((col1 & 2) != 2)
	{
		column = 1;
	}
    else if ((col2 & 0x20) != 0x20)
	{
		column = 2;
	}

	if (column != 20)
	{
		setHigh(PORTB, PB0);
		setHigh(PORTB, PB1);
		setHigh(PORTB, PB2);
		setHigh(PORTB, PB3);
		setHigh(PORTB, PB4);
		setLow(PORTA, PA0);
		setLow(PORTA, PA1);
		setLow(PORTB, PB5);

		//keyboard rows
		setInput(DDRB, PB0);
		setInput(DDRB, PB1);
		setInput(DDRB, PB2);
		setInput(DDRB, PB3);
		setInput(DDRB, PB4);

		//keyboard columns
		setOutput(DDRA, PA0);
		setOutput(DDRA, PA1);
		setOutput(DDRB, PB5);

		col1 = PINB;
		unsigned char i;
		unsigned char mask = 0x1;
		for (i = 0; i < 5; i++)
		{
			if ((PINB & mask) != mask)
			{
				row = i;
			}
			mask <<= 1;
		}
//1 -> 2
//2 -> 5
//3 -> 4
//4 -> 3
//should be 0 -> 4, 1 -> 0, 4 -> 1, 3<->2
		//keyboard rows
		setOutput(DDRB, PB0);
		setOutput(DDRB, PB1);
		setOutput(DDRB, PB2);
		setOutput(DDRB, PB3);
		setOutput(DDRB, PB4);
		setLow(PORTB, PB0);
		setLow(PORTB, PB1);
		setLow(PORTB, PB2);
		setLow(PORTB, PB3);
		setLow(PORTB, PB4);
		//keyboard columns
		setInput(DDRA, PA0);
		setInput(DDRA, PA1);
		setInput(DDRB, PB5);
		setHigh(PORTA, PA0);
		setHigh(PORTA, PA1);
		setHigh(PORTB, PB5);
	}
	if (column == 20 || row == 20 || row == 0)
	{
		return 0xFF;
	}
	if (row == 1)
	{
		return 1 + column;
	}
	if (row == 2)
	{
		if (column != 1)
			return 0xFF;
		return 0;
	}
	if (row == 3)
	{
		return 7 + column;
	}
	if (row == 4)
	{
		return 4 + column;
	}
	return 0xFF;

/* NIGHT
	lcd_fillRect(30, 30, 54, 70, 0x03);
	if (row != 20 && column != 20)
	{
		lcd_fillRect(30 + (column << 3), 30 + (row << 3), 38 + (column << 3), 38 + (row << 3), 0xE0);
	}
	lcd_fillRect(30, 20, 54, 28, 0x03);
	if (column != 20)
	{
		lcd_fillRect(30+(column<<3), 20, 38+(column<<3), 28, 0xE0);
	}
*/

/*
	unsigned char col1 = PINA;
	unsigned char col2 = PINB;
	unsigned char column = 20;
	if ((col1 & 1) != 1)
	{
		column = 0;
	}
	else if ((col1 & 2) != 2)
	{
		column = 1;
	}
    else if ((col2 & 0x20) != 0x20)
	{
		column = 2;
	}

	lcd_fillRect(30, 30, 54, 38, 0x03);
	if (column != 20)
	{
		lcd_fillRect(30+(column<<3), 30, 38+(column<<3), 38, 0xE0);
	}
*/
	/*
	if ((PINA & 3) == 3 && (PINB & 0x20) == 0x20)
	{
		lcd_fillRect(30, 30, 38, 38, 0x03);
	}
	else
	{
		lcd_fillRect(30, 30, 38, 38, 0xE0);
	}
	*/
//	return 0;
}

unsigned char previous_key = 0xFF;
unsigned char pressed_count = 0;

unsigned char encode_value(unsigned char mask)
{
	return mask * 25;
}

void process_key( unsigned char pressed_key )
{
	if (pressed_key == previous_key || pressed_key == 0xFF)
		return;
//	unsigned char i = 0;
//	unsigned short mask = 1;
//	for (mask = 1; mask; mask <<= 1)
//	{
//		if ( pressed_key_mask & mask )
//		{
//			break;
//		}
//		i++;
//	}
	pressed_count += 1;
	previous_key = pressed_key;
	unsigned short n = 1 + ((pressed_count * 232) % 23231);
	unsigned char x = n % 132;
	unsigned char y = n / 132;
	lcd_fillRect(x, y, x, y, encode_value(pressed_key));
//	lcd_fillRect(0, 0, 131, 175, encode_value(pressed_key));
	lcd_fillRect(0, 0, 0, 0, encode_value(pressed_count));
}

unsigned char rn_q = 0;
unsigned char rn_g = 0;
unsigned char rn_x = 0;
unsigned char rn_a = 1;
unsigned char rn_b = 1;
#define rn_hi 1
#define rn_nu 2
#define rn_Ha 2
#define rn_Hb 2

unsigned char RotL(value, shift)
{
	return ((value << shift) | (value >> (8 - shift))) & 255;
}

unsigned short rand()
{
	unsigned char z = rn_g;
	unsigned char r = rn_q;
	rn_q = z ^ RotL(rn_x, rn_hi);
	rn_g = r ^ RotL(z, rn_nu);
	rn_x = (rn_a * z + rn_b) & 255;
	rn_a += rn_Ha;
	rn_b += rn_Hb;
	return r;
}

void random_fill()
{
	lcd_sendCommand(0x2A);
	lcd_sendData(0);
	lcd_sendData(131);
	lcd_sendCommand(0x2B);
	lcd_sendData(0);
	lcd_sendData(175);
	lcd_sendCommand(0x2C);
	unsigned short i;
	for ( i = 0; i < 23232; i++ )
	{
		lcd_sendData( rand() % 256 );
	}
/*	unsigned char j;
	for ( j = 0; j < 10; j++ )
	{
		lcd_fillRect(j * 10, 0, j*10 + 10, 10, j * 25);
	}*/
}

int main(void)
{
	totalCount = 0;
	init_io();
	lcd_init();
	random_fill();
	//lcd_fillRect(10, 10, 122, 166, 0xFF);
	//lcd_fillRect(20, 20, 112, 156, 0x00);
	unsigned short keyboard_state, previous_state, pressed_key;
	previous_state = 0;
    for(;;)
    {
/*    	keyboard_state = get_keyboard_state();
		pressed_key = (keyboard_state ^ previous_state) & previous_state;
		if (pressed_key)
		{
			process_key(pressed_key);
		}
		previous_state = keyboard_state;
*/
		pressed_key = get_keyboard_state();
		process_key(pressed_key);
    }

    return 0;
}