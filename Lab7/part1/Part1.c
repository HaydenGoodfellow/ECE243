
//include boolean header library for true and false
#include <stdbool.h>

//pixel_buffer_start points to the pixel buffer address
volatile int pixel_buffer_start; 

//initiallize functions to be used in main
void plot_pixel(int x1,int y1, short int pixel_colour);
void draw_line(int x1, int y1, int x2, int y2, short int line_colour);
void clear_screen();
void swap(int * x, int * y);


//main function loop 
int main(void){

    //pointer to the pixel controller address
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
    
    /* Read location of the pixel buffer from the pixel buffer controller */
    pixel_buffer_start = *pixel_ctrl_ptr;

    //clear the screen initially to set the background to black
    clear_screen();

    //draw 4 lines of different colours at following points
    draw_line(0, 0, 150, 150, 0x001F); // this line is blue
    draw_line(150, 150, 319, 0, 0x07E0); // this line is green
    draw_line(0, 239, 319, 239, 0xF800); // this line is red
    draw_line(319, 0, 0, 239, 0xF81F); // this line is a pink color

    //keep the program running and prevent the program from ending
    while(true){
    }

    return 0;
}

//draw_line function, draws a line between 2 points in the specified pixel colour
void draw_line(int x1, int y1, int x2, int y2, short int line_colour){
    
    //initialize is_steep to false
    int is_steep = false; 
    int abs_y = y2 - y1; 
    int abs_x = x2 - x1;
    
    if (abs_y < 0 ) abs_y =-abs_y; //change sign if negative
    if (abs_x < 0) abs_x = -abs_x;
    
    if (abs_y > abs_x) is_steep=1; //TRUE
    
    //swap x and y point if the line is steep
    if (is_steep) {
        swap(&x1, &y1);
        swap(&x2, &y2);
    }
   
    //if point 2 is before point 1, swap the x and y values to allow draw from left to right
    if (x1>x2) {
        swap(&x1, &x2);
        swap(&y1, &y2);
    }
    
    //initialize delta_x and y values
    int delta_x = x2 - x1;
    int delta_y = y2 - y1;
    
    //cant have negative value for delta y, set it to positive, same as using abs()
    if (delta_y <0) 
        delta_y = -delta_y;
    
    
    int error = -(delta_x / 2);
    int draw_y = y1;
    int y_step;
        
    // change the step value according to which y value is bigger
    if (y1 < y2)
        y_step = 1;
    else 
        y_step = -1;
    
    //bresenhams algorithm loop
    for(int draw_x=x1; draw_x <= x2; draw_x++) {
        if (is_steep == true)
            plot_pixel(draw_y,draw_x, line_colour);
        else 
            plot_pixel(draw_x,draw_y, line_colour);
        
        error += delta_y;
        
        if (error>=0) {
            draw_y += y_step;
            error -= delta_x;
        }
    } 

}

void clear_screen(){

    //initialize variables to iterate through the pixels
    int x;
	int y;
	
    //go over each pixel in the vga display and set the colour of the pixel to black
    for (x = 0; x < 320; x++)
		for (y = 0; y < 240; y++)
			plot_pixel(x, y, 0x0000);	

}

//Function that plots a pixel on the VGA Display
void plot_pixel(int x, int y, short int line_color)
{
    *(short int *)(pixel_buffer_start + (y << 10) + (x << 1)) = line_color;
}

//helper function to switch 2 variable values with eachother 
void swap(int * x, int * y){
	int temp = *x;
    *x = *y;
    *y = temp;   
}