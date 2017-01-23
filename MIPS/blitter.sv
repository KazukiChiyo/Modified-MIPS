/*module blitter( input[9:0] figure1positionx,
					 input[9:0] figure1positiony,
					 input[2:0]	status,
					 input[3:0] run1data,
					 input[3:0] run2data,
					 input[3:0] fightdata,
					 input[3:0] fight1data,
					 input[3:0] kick1data,
					 input[3:0] kick2data,
					 input[3:0] stand,
					 input[3:0] inputdata,
					 output[18:0]inputaddress,
					 output[18:0]outputaddress,
					 output[3:0]outputdata,
					 output  WE
						);
				enum logic[3:0] (start,readdata,writedata)*/
				
module blitter(
					input logic[9:0]  DrawX, DrawY, 
					input logic [2:0] data1,
					input logic frame_clk,
					input logic [3:0] c1,c2,c3,c4,c5,c6,c7,c8,
					output logic [7:0]  Red, Green, Blue);
					
logic [7:0] data;
logic [10:0] addr;
//logic [9:0] positionX;
//logic [9:0] positionY;
logic shape_on, background,shape_on_z,shape_on_e1,shape_on_e2,shape_on_s,shape_on_i1,shape_on_i2,shape_on_i3,shape_on_f1,shape_on_f2,shape_on_f3,shape_on_t1,shape_on_t2,shape_on_t3;//, shape_on1;
logic [9:0] z=10'd280;
logic [9:0] e1=10'd290;
logic [9:0] s=10'd300;
logic [9:0] e2=10'd310;
logic [9:0] i1=10'd320;
logic [9:0] i2=10'd330;
logic [9:0] i3=10'd340;
logic [9:0] f1=10'd350;
logic [9:0] f2=10'd260;
logic [9:0] f3=10'd270;
logic [9:0] t1=10'd260;
logic [9:0] t2=10'd270;
logic [9:0] t3=10'd280;
logic [9:0] zero=10'd20;
logic [9:0] one=10'd80;
logic [9:0] two=10'd240;
logic [9:0] yco1=10'd240;
logic [9:0] yco2=10'd220;
logic [9:0] yco3=10'd60;
logic [9:0] yco4=10'd80;
logic [9:0] co1,co2,co3,co4,co5,co6,co7,co8;
logic [9:0] zeroco=10'h30;
logic [9:0] xco=10'h78;
logic [9:0] oco=10'h4f;
logic [9:0] uco=10'h55;
logic [9:0] tco=10'h54;
always_comb begin
if(c1<=9)
 co1=10'h30+c1;
else 
 co1=10'h57+c1;
if(c2<=9) 
co2=10'h30+c2;
else
 co2=10'h57+c2;
if(c3<=9) 
co3=10'h30+c3;
else
 co3=10'h57+c3;
 if(c4<=9) 
co4=10'h30+c4;
else
 co4=10'h57+c4;
if(c5<=9) 
co5=10'h30+c5;
else
 co5=10'h57+c5; 
if(c6<=9) 
co6=10'h30+c6;
else
 co6=10'h57+c6; 
 if(c7<=9) 
co7=10'h30+c7;
else
 co7=10'h57+c7;
 if(c8<=9) 
co8=10'h30+c8;
else
 co8=10'h57+c8;
 end





//logic [99:0] counter;
//enum logic[3:0] {Wait, Paint} state, next_state;

//assign positionX = 10'd200;
//assign positionY = 10'd300;
logic[10:0]  shape_size_x = 8;
logic[10:0]  shape_size_y = 16;
/*standpic standpic0(.addr(addr), .frame_clk(frame_clk),
                   .data(data));*/

font_rom font_rom0(.addr(addr),.data(data));

always_comb	begin
if(DrawX >= z && DrawX < (z + shape_size_x) &&
   DrawY >= yco1 && DrawY < (yco1 + shape_size_y))
    begin 
	 addr = 	16*co1+(DrawY-yco1);
	 shape_on_z = 1'b1;
	 shape_on_e1=1'b0;
	 shape_on_s=1'b0;
	 shape_on_e2=1'b0;
	 shape_on_i1=1'b0;
	 shape_on_i2=1'b0;
	 shape_on_i3=1'b0;
	 shape_on_f1=1'b0;
	 shape_on_f2=1'b0;
	 shape_on_f3=1'b0;
	 shape_on_t1=1'b0;
	 shape_on_t2=1'b0;
	 shape_on_t3=1'b0;
	 background = 1'b0;
// 	 shape_on1 = 1'b0;
	 end
else if (DrawX >= e1 && DrawX < (e1 + shape_size_x) &&
   DrawY >= yco1 && DrawY < (yco1 + shape_size_y))
    begin 
	 addr = 	co2*16+(DrawY-yco1);
	 shape_on_z = 1'b0;
	 shape_on_e1=1'b1;
	 shape_on_s=1'b0;
	 shape_on_e2=1'b0;
	 shape_on_i1=1'b0;
	 shape_on_i2=1'b0;
	 shape_on_i3=1'b0;
	 shape_on_f1=1'b0;
	 shape_on_f2=1'b0;
	 shape_on_f3=1'b0;
	 shape_on_t1=1'b0;
	 shape_on_t2=1'b0;
	 shape_on_t3=1'b0;
	 background = 1'b0;
// 	 shape_on1 = 1'b0;
	 end
else if (DrawX >= s && DrawX < (s + shape_size_x) &&
   DrawY >= yco1 && DrawY < (yco1 + shape_size_y))
    begin 
	 addr = 	co3*16+(DrawY-yco1);
	 shape_on_z = 1'b0;
	 shape_on_e1=1'b0;
	 shape_on_s=1'b1;
	 shape_on_e2=1'b0;
	 shape_on_i1=1'b0;
	 shape_on_i2=1'b0;
	 shape_on_i3=1'b0;
	 shape_on_f1=1'b0;
	 shape_on_f2=1'b0;
	 shape_on_f3=1'b0;
	 shape_on_t1=1'b0;
	 shape_on_t2=1'b0;
	 shape_on_t3=1'b0;
	 background = 1'b0;
// 	 shape_on1 = 1'b0;
	 end
else if (DrawX >= e2 && DrawX < (e2 + shape_size_x) &&
   DrawY >= yco1 && DrawY < (yco1 + shape_size_y))
    begin 
	 addr = 	co4*16+(DrawY-yco1);
	 shape_on_z = 1'b0;
	 shape_on_e1=1'b0;
	 shape_on_s=1'b0;
	 shape_on_e2=1'b1;
	 shape_on_i1=1'b0;
	 shape_on_i2=1'b0;
	 shape_on_i3=1'b0;
	 shape_on_f1=1'b0;
	 shape_on_f2=1'b0;
	 shape_on_f3=1'b0;
	 shape_on_t1=1'b0;
	 shape_on_t2=1'b0;
	 shape_on_t3=1'b0;
	 background = 1'b0;
// 	 shape_on1 = 1'b0;
	 end
else if (DrawX >= i1 && DrawX < (i1 + shape_size_x) &&
   DrawY >= yco1 && DrawY < (yco1 + shape_size_y))
    begin 
	 addr = 	co5*16+(DrawY-yco1);
	 shape_on_z = 1'b0;
	 shape_on_e1=1'b0;
	 shape_on_s=1'b0;
	 shape_on_e2=1'b0;
	 shape_on_i1=1'b1;
	 shape_on_i2=1'b0;
	 shape_on_i3=1'b0;
	 shape_on_f1=1'b0;
	 shape_on_f2=1'b0;
	 shape_on_f3=1'b0;
	 shape_on_t1=1'b0;
	 shape_on_t2=1'b0;
	 shape_on_t3=1'b0;
	 background = 1'b0;
// 	 shape_on1 = 1'b0;
	 end
else if (DrawX >= i2 && DrawX < (i2 + shape_size_x) &&
   DrawY >= yco1 && DrawY < (yco1 + shape_size_y))
    begin 
	 addr = 	co6*16+(DrawY-yco1);
	 shape_on_z = 1'b0;
	 shape_on_e1=1'b0;
	 shape_on_s=1'b0;
	 shape_on_e2=1'b0;
	 shape_on_i1=1'b0;
	 shape_on_i2=1'b1;
	 shape_on_i3=1'b0;
	 shape_on_f1=1'b0;
	 shape_on_f2=1'b0;
	 shape_on_f3=1'b0;
	 shape_on_t1=1'b0;
	 shape_on_t2=1'b0;
	 shape_on_t3=1'b0;
	 background = 1'b0;
// 	 shape_on1 = 1'b0;
	 end
else if (DrawX >= i3 && DrawX < (i3 + shape_size_x) &&
   DrawY >= yco1 && DrawY < (yco1 + shape_size_y))
    begin 
	 addr = 	co7*16+(DrawY-yco1);
	 shape_on_z = 1'b0;
	 shape_on_e1=1'b0;
	 shape_on_s=1'b0;
	 shape_on_e2=1'b0;
	 shape_on_i1=1'b0;
	 shape_on_i2=1'b0;
	 shape_on_i3=1'b1;
	 shape_on_f1=1'b0;
	 shape_on_f2=1'b0;
	 shape_on_f3=1'b0;
	 shape_on_t1=1'b0;
	 shape_on_t2=1'b0;
	 shape_on_t3=1'b0;
	 background = 1'b0;
// 	 shape_on1 = 1'b0;
	 end
else if (DrawX >= f1 && DrawX < (f1 + shape_size_x) &&
   DrawY >= yco1 && DrawY < (yco1 + shape_size_y))
    begin 
	 addr = 	co8*16+(DrawY-yco1);
	 shape_on_z = 1'b0;
	 shape_on_e1=1'b0;
	 shape_on_s=1'b0;
	 shape_on_e2=1'b0;
	 shape_on_i1=1'b0;
	 shape_on_i2=1'b0;
	 shape_on_i3=1'b0;
	 shape_on_f1=1'b1;
	 shape_on_f2=1'b0;
	 shape_on_f3=1'b0;
	 shape_on_t1=1'b0;
	 shape_on_t2=1'b0;
	 shape_on_t3=1'b0;
	 background = 1'b0;
// 	 shape_on1 = 1'b0;
	 end
else if (DrawX >= f2 && DrawX < (f2 + shape_size_x) &&
   DrawY >= yco1 && DrawY < (yco1 + shape_size_y))
    begin 
	 addr = 	zeroco*16+(DrawY-yco1);
	 shape_on_z = 1'b0;
	 shape_on_e1=1'b0;
	 shape_on_s=1'b0;
	 shape_on_e2=1'b0;
	 shape_on_i1=1'b0;
	 shape_on_i2=1'b0;
	 shape_on_i3=1'b0;
	 shape_on_f1=1'b0;
	 shape_on_f2=1'b1;
	 shape_on_f3=1'b0;
	 shape_on_t1=1'b0;
	 shape_on_t2=1'b0;
	 shape_on_t3=1'b0;
	 background = 1'b0;
// 	 shape_on1 = 1'b0;
	 end
else if (DrawX >= f3 && DrawX < (f3 + shape_size_x) &&
   DrawY >= yco1 && DrawY < (yco1 + shape_size_y))
    begin 
	 addr = 	xco*16+(DrawY-yco1);
	 shape_on_z = 1'b0;
	 shape_on_e1=1'b0;
	 shape_on_s=1'b0;
	 shape_on_e2=1'b0;
	 shape_on_i1=1'b0;
	 shape_on_i2=1'b0;
	 shape_on_i3=1'b0;
	 shape_on_f1=1'b0;
	 shape_on_f2=1'b0;
	 shape_on_f3=1'b1;
	 shape_on_t1=1'b0;
	 shape_on_t2=1'b0;
	 shape_on_t3=1'b0;
	 background = 1'b0;
// 	 shape_on1 = 1'b0;
	 end
else if (DrawX >= t1 && DrawX < (t1 + shape_size_x) &&
   DrawY >= yco2 && DrawY < (yco2 + shape_size_y))
    begin 
	 addr = 	oco*16+(DrawY-yco2);
	 shape_on_z = 1'b0;
	 shape_on_e1=1'b0;
	 shape_on_s=1'b0;
	 shape_on_e2=1'b0;
	 shape_on_i1=1'b0;
	 shape_on_i2=1'b0;
	 shape_on_i3=1'b0;
	 shape_on_f1=1'b0;
	 shape_on_f2=1'b0;
	 shape_on_f3=1'b0;
	 shape_on_t1=1'b1;
	 shape_on_t2=1'b0;
	 shape_on_t3=1'b0;
	 background = 1'b0;
// 	 shape_on1 = 1'b0;
	 end
else if (DrawX >= t2 && DrawX < (t2 + shape_size_x) &&
   DrawY >= yco2 && DrawY < (yco2 + shape_size_y))
    begin 
	 addr = 	uco*16+(DrawY-yco2);
	 shape_on_z = 1'b0;
	 shape_on_e1=1'b0;
	 shape_on_s=1'b0;
	 shape_on_e2=1'b0;
	 shape_on_i1=1'b0;
	 shape_on_i2=1'b0;
	 shape_on_i3=1'b0;
	 shape_on_f1=1'b0;
	 shape_on_f2=1'b0;
	 shape_on_f3=1'b0;
	 shape_on_t1=1'b0;
	 shape_on_t2=1'b1;
	 shape_on_t3=1'b0;
	 background = 1'b0;
// 	 shape_on1 = 1'b0;
	 end
else if (DrawX >= t3 && DrawX < (t3 + shape_size_x) &&
   DrawY >= yco2 && DrawY < (yco2 + shape_size_y))
    begin 
	 addr = 	tco*16+(DrawY-yco2);
	 shape_on_z = 1'b0;
	 shape_on_e1=1'b0;
	 shape_on_s=1'b0;
	 shape_on_e2=1'b0;
	 shape_on_i1=1'b0;
	 shape_on_i2=1'b0;
	 shape_on_i3=1'b0;
	 shape_on_f1=1'b0;
	 shape_on_f2=1'b0;
	 shape_on_f3=1'b0;
	 shape_on_t1=1'b0;
	 shape_on_t2=1'b0;
	 shape_on_t3=1'b1;
	 background = 1'b0;
// 	 shape_on1 = 1'b0;
	 end		 
	 else 
	 begin
	 shape_on_z = 1'b0;
	 shape_on_e1=1'b0;
	 shape_on_s=1'b0;
	 shape_on_e2=1'b0;
	 shape_on_i1=1'b0;
	 shape_on_i2=1'b0;
	 shape_on_i3=1'b0;
	 shape_on_f1=1'b0;
	 shape_on_f2=1'b0;
	 shape_on_f3=1'b0;
	 shape_on_t1=1'b0;
	 shape_on_t2=1'b0;
	 shape_on_t3=1'b0;
	 background = 1'b0;
	 addr = 10'b0;
	 end
end
	 
always_comb
begin
	if((shape_on_z == 1'b1) && data[7-(DrawX-z)] == 1'b1)
	begin
		Red = 8'h00;
		Green = 8'h00;
		Blue = 8'h00;
	end
	else	if((shape_on_e1 == 1'b1) && data[7-(DrawX-e1)] == 1'b1)
	begin
		Red = 8'h00;
		Green = 8'h00;
		Blue = 8'h00;
	end
	else	if((shape_on_s == 1'b1) && data[7-(DrawX-s)] == 1'b1)
	begin
		Red = 8'h00;
		Green = 8'h00;
		Blue = 8'h00;
	end
	else	if((shape_on_i1 == 1'b1) && data[7-(DrawX-i1)] == 1'b1)
	begin
		Red = 8'h00;
		Green = 8'h00;
		Blue = 8'h00;
	end
	else	if((shape_on_i2 == 1'b1) && data[7-(DrawX-i2)] == 1'b1)
	begin
		Red = 8'h00;
		Green = 8'h00;
		Blue = 8'h00;
	end
	else	if((shape_on_i3 == 1'b1) && data[7-(DrawX-i3)] == 1'b1)
	begin
		Red = 8'h00;
		Green = 8'h00;
		Blue = 8'h00;
	end
	else	if((shape_on_f1 == 1'b1) && data[7-(DrawX-f1)] == 1'b1)
	begin
		Red = 8'h00;
		Green = 8'h00;
		Blue = 8'h00;
	end
	else	if((shape_on_f2 == 1'b1) && data[7-(DrawX-f2)] == 1'b1)
	begin
		Red = 8'h00;
		Green = 8'h00;
		Blue = 8'h00;
	end
	else	if((shape_on_f3 == 1'b1) && data[7-(DrawX-f3)] == 1'b1)
	begin
		Red = 8'h00;
		Green = 8'h00;
		Blue = 8'h00;
	end
	else	if((shape_on_t1 == 1'b1) && data[7-(DrawX-t1)] == 1'b1)
	begin
		Red = 8'h00;
		Green = 8'h00;
		Blue = 8'h00;
	end
	else	if((shape_on_t2 == 1'b1) && data[7-(DrawX-t2)] == 1'b1)
	begin
		Red = 8'h00;
		Green = 8'h00;
		Blue = 8'h00;
	end
	else	if((shape_on_t3 == 1'b1) && data[7-(DrawX-t3)] == 1'b1)
	begin
		Red = 8'h00;
		Green = 8'h00;
		Blue = 8'h00;
	end	
	else	if((shape_on_e2 == 1'b1) && data[7-(DrawX-e2)] == 1'b1)
	begin
		Red = 8'h00;
		Green = 8'h00;
		Blue = 8'h00;
	end	
	
	else
			 begin 
            Red = 8'hff; 
            Green = 8'hff;
            Blue = 8'hff ;//- DrawX[9:3]
        end
end
	
endmodule						