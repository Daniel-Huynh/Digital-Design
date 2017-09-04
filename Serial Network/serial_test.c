/* 
 * This game allows 2 people to play rock paper scissors on 2 altera FPGA's
 *           Function                  Description
 *        ===============  =====================================
 *        alt_printf       Only supports %s, %x, and %c ( < 1 Kbyte)
 *        alt_putstr       Smaller overhead than puts with direct drivers
 *                         Note this function doesn't add a newline.
 *        alt_putchar      Smaller overhead than putchar with direct drivers
 *        alt_getchar      Smaller overhead than getchar with direct drivers
 *
 */

#include "sys/alt_stdio.h"
#include "stdint.h"
#include "system.h"
#include "altera_avalon_jtag_uart_regs.h"
#include "altera_avalon_pio_regs.h"
#include "unistd.h"

void send_msg(uint8_t msg_data) {
	uint8_t status;
	IOWR_ALTERA_AVALON_PIO_DATA(TRANSMIT_DATA_BASE, msg_data);
	IOWR_ALTERA_AVALON_PIO_DATA(CONTROL_BASE, 0x01);
	IOWR_ALTERA_AVALON_PIO_DATA(CONTROL_BASE, 0x02);
	do {
		status = IORD_ALTERA_AVALON_PIO_DATA(STATUS_BASE);
	} while (!(0x02 & status));
	IOWR_ALTERA_AVALON_PIO_DATA(CONTROL_BASE, 0x00);
}

uint8_t receive_msg() {
	uint8_t receive_data, status;
	do {
		receive_data = IORD_ALTERA_AVALON_PIO_DATA(RECEIVE_DATA_BASE);
		status = IORD_ALTERA_AVALON_PIO_DATA(STATUS_BASE);
	} while (!(0x01 & status));
	IOWR_ALTERA_AVALON_PIO_DATA(CONTROL_BASE, 0x04);
	return receive_data;
}

uint8_t winner(uint8_t move_p1, uint8_t move_p2) {
	uint8_t win;
	if ((move_p1 == 0x01 && move_p2 == 0x01) ||
			(move_p1 == 0x02 && move_p2 == 0x02) ||
			(move_p1 == 0x03 && move_p2 == 0x03)) {
		alt_printf("We think: Tie!\n");
		win = 0x03;
	} else if ((move_p1 == 0x01 && move_p2 == 0x02) ||
			(move_p1 == 0x02 && move_p2 == 0x03) ||
			(move_p1 == 0x03 && move_p2 == 0x01)) {
		alt_printf("We think: Player 2 wins!\n");
		win = 0x02;
	} else {
		alt_printf("We think: Player 1 wins!\n");
		win = 0x01;
	}
	return win;
}

int main()
{

		// User sets up input,
		// When started read sw once!
		uint8_t sw, leds;
		sw = 0x00;
		leds = 0x00;
		alt_printf("\n\nLet's play Rock, Paper, Scissors!\n");
		while (!(sw & 0x80)) {
			sw = IORD_ALTERA_AVALON_PIO_DATA(SWITCHES_BASE);
			leds = sw & 0x03;
			if (sw & 0x40) {
				leds |= 0x40;

			} else if (!(sw & 0x40)) {
				leds |= 0x80;
			}
			// Compute moves etc & set LEDs TODO TODO
			IOWR_ALTERA_AVALON_PIO_DATA(LEDS_BASE, leds);
		}
//		alt_putstr("Starting!\n");
//		uint8_t msg = receive_msg();
//		alt_putstr("Done with receive!\n");
//		alt_printf("Got: 0x%x\n", msg);
//		send_msg(0x3C);
//		alt_putstr("Done with send 0x3C!\n");
		// Game has started, we know our values.
		if (sw & 0x40) { // If SW7, we're Player 1 and we start the game
			alt_printf("We're player 1\n");
			// Send START NOW
			send_msg(0xF0);
			// Get & Check START OK
			uint8_t response = receive_msg();
			if (response != 0xF1) {
				alt_printf("Bad start ok, got: 0x%x\n", response);
			} else {
				alt_printf("Good start ok, got: 0x%x\n", response);
			}

			// Compute our move, ensure Rock 01 Paper 10 or Scissors 11, and send it
			uint8_t move_p1 = sw & 0x03;
			if (move_p1 == 0x00) {
				alt_printf("Bad move our: 0x%x\n", move_p1);
			} else {
				alt_printf("Good move our: 0x%x\n", move_p1);
			}
			send_msg(0x90 | move_p1);
			// Get the other player's move, and display it
			uint8_t move_p2 = receive_msg();
			if ((move_p2 & 0xFC) != 0x90) {  // Mask bottom 2 bits and check header is correct
				alt_printf("Bad move resp other, got: 0x%x\n", move_p2);
			} else {
				alt_printf("Good move resp other, got: 0x%x\n", move_p2);
			}
			move_p2 &= 0x03;
			if (move_p2 == 0x00) {
				alt_printf("Bad move other: 0x%x\n", move_p2);
			} else {
				alt_printf("Good move other: 0x%x\n", move_p2);
			}
			leds |= move_p2 << 2;

			// Send who we think the winner is
			uint8_t win_our = winner(move_p1, move_p2);
			send_msg(0x30 | win_our);
			// Get who they think the winner is
			uint8_t win_other = receive_msg();
			if ((win_other & 0xFC) != 0x30) {
				alt_printf("Bad win resp other, got: 0x%x\n", win_other);
			} else {
				alt_printf("Good win resp other, got: 0x%x\n", win_other);
			}
			win_other &= 0x03;
			if (win_other == 0x00) {
				alt_printf("Bad win indicator other: 0x%x\n", win_other);
			} else {
				alt_printf("Good win indicator other: 0x%x\n", win_other);
			}
			if (win_our != win_other) {
				alt_printf("No agreement on winner, our: 0x%x, other:0x%x\n", win_our, win_other);
			} else {
				alt_printf("Agreement on winner, our: 0x%x, other:0x%x\n", win_our, win_other);
			}
			leds |= win_other << 4;
			IOWR_ALTERA_AVALON_PIO_DATA(LEDS_BASE, leds);
		} else {  // o.w., we're Player 2 and listen
			alt_printf("We're player 2\n");
			// Get & Check START now
			uint8_t response;
			response = receive_msg();
			if (response != 0xF0) {
				alt_printf("Bad start now, got: 0x%x\n", response);
			} else {
				alt_printf("Good start now, got: 0x%x\n", response);
			}
			// Send START ok
			send_msg(0xF1);

			// Get the other player's move, and display it
			uint8_t move_p1 = receive_msg();
			if ((move_p1 & 0xFC) != 0x90) {  // Mask bottom 2 bits and check header is correct
				alt_printf("Bad move resp other, got: 0x%x\n", move_p1);
			} else {
				alt_printf("Good move resp other, got: 0x%x\n", move_p1);
			}
			move_p1 &= 0x03;
			if (move_p1 == 0x00) {
				alt_printf("Bad move other: 0x%x\n", move_p1);
			} else {
				alt_printf("Good move other: 0x%x\n", move_p1);
			}
			leds |= move_p1 << 2;
			// Compute our move, ensure Rock 01 Paper 10 or Scissors 11, and send it
			uint8_t move_p2 = sw & 0x03;
			if (move_p2 == 0x00) {
				alt_printf("Bad move our: 0x%x\n", move_p2);
			} else {
				alt_printf("Good move our: 0x%x\n", move_p2);
			}
			send_msg(0x90 | move_p2);

			// Get who they think the winner is
			uint8_t win_other = receive_msg();
			if ((win_other & 0xFC) != 0x30) {
				alt_printf("Bad win resp other, got: 0x%x\n", win_other);
			} else {
				alt_printf("Good win resp other, got: 0x%x\n", win_other);
			}
			win_other &= 0x03;
			if (win_other == 0x00) {
				alt_printf("Bad win indicator other: 0x%x\n", win_other);
			} else {
				alt_printf("Good win indicator other: 0x%x\n", win_other);
			}
			// Send who we think the winner is
			uint8_t win_our = winner(move_p1, move_p2);
			send_msg(0x30 | win_our);
			if (win_our != win_other) {
				alt_printf("No agreement on winner, our: 0x%x, other:0x%x\n", win_our, win_other);
			} else {
				alt_printf("Agreement on winner, our: 0x%x, other:0x%x\n", win_our, win_other);
			}
			leds |= win_other << 4;
			IOWR_ALTERA_AVALON_PIO_DATA(LEDS_BASE, leds);
		}
		return 0;
}
