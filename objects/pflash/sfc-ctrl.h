#ifndef SFC_CTRL_H
#define SFC_CTRL_H

struct spi_flash_ctrl;

extern int sfc_open(struct spi_flash_ctrl **ctrl);
extern void sfc_close(struct spi_flash_ctrl *ctrl);

#endif /* SFC_CTRL_H */
