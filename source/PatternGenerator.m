%% 0. Specify details:
clear;clc;
folderlocation = '../../Publications/2012_xx_Array_Integration/Images/07_Write_Read/Final/Patterns/';
runname = '47';

% Translation distances:
actran = [0.675, -0.675].*1E-6;
ditran = [3.7125, -2.3625].*1E-6;
eltran = [1.2025, -1.35].*1E-6;
mitran = [4.05,-3.375].*1E-6;
retran = [1.6875, -2.3625].*1E-6;

% Double check that the displacements are integer multiples of dx
disp(actran/0.3375E-6)
disp(ditran/0.3375E-6)
disp(eltran/0.3375E-6)
disp(mitran/0.3375E-6)
disp(retran/0.3375E-6)

disp('Step 0: Check that the displacements are integer multiples of 0.3375');

%% Compensatory additional translation:
W1dx = -425E-9;
W1dy = -25E-9;
W2dx = -550E-9;
W2dy = -25E-9;

actran = CompensateDrift(actran, W1dx, W1dy, W2dx, W2dy);
ditran = CompensateDrift(ditran, W1dx, W1dy, W2dx, W2dy);
eltran = CompensateDrift(eltran, W1dx, W1dy, W2dx, W2dy);
mitran = CompensateDrift(mitran, W1dx, W1dy, W2dx, W2dy);
retran = CompensateDrift(retran, W1dx, W1dy, W2dx, W2dy);

fprintf('Additionally W1 moved by %d nm right and %d nm up\n',W1dx*1E+9,W1dy*1E+9);
fprintf('And W2 moved by %d nm right and %d nm up\n',W2dx*1E+9,W2dy*1E+9);
clear('W1dx','W1dy','W2dx','W2dy','ans');

%% 1. Load all patterns:

Actuator_W1 = ExtractPattern(strcat(folderlocation,'Actuator_W1.txt'));
Actuator_W2 = ExtractPattern(strcat(folderlocation,'Actuator_W2.txt'));

Diffusion_W1 = ExtractPattern(strcat(folderlocation,'Diffusion_Rxn_W1.txt'));
Diffusion_W2 = ExtractPattern(strcat(folderlocation,'Diffusion_Rxn_W2.txt'));

Electrical_W1 = ExtractPattern(strcat(folderlocation,'Electrical_Circuit_W1.txt'));
Electrical_W2 = ExtractPattern(strcat(folderlocation,'Electrical_Circuit_W2.txt'));

Microfluidic_W1 = ExtractPattern(strcat(folderlocation,'Microfluidic_W1.txt'));
Microfluidic_W2 = ExtractPattern(strcat(folderlocation,'Microfluidic_W2.txt'));

Resonator_W1 = ExtractPattern(strcat(folderlocation,'Resonator_W1.txt'));
Resonator_W2 = ExtractPattern(strcat(folderlocation,'Resonator_W2.txt'));

disp('Step 1: Patterns loaded');

%% 2. Translate by specified amount:

[Actuator_W1,Actuator_W2] = TranslatePatternPair(Actuator_W1,Actuator_W2,actran);

[Diffusion_W1,Diffusion_W2] = TranslatePatternPair(Diffusion_W1,Diffusion_W2,ditran);

[Electrical_W1,Electrical_W2] = TranslatePatternPair(Electrical_W1,Electrical_W2,eltran);

[Microfluidic_W1,Microfluidic_W2] = TranslatePatternPair(Microfluidic_W1,Microfluidic_W2,mitran);

[Resonator_W1,Resonator_W2] = TranslatePatternPair(Resonator_W1,Resonator_W2,retran);

disp('Step 2: Patterns translated')

%% 3. Write Translated Files:

folderlocation = strcat(folderlocation,'/Run_',runname,'/');
mkdir(folderlocation);

WritePattern(strcat(folderlocation,'Run_',runname,'_Actuator_W1.txt'),Actuator_W1);
WritePattern(strcat(folderlocation,'Run_',runname,'_Actuator_W2.txt'),Actuator_W2);

WritePattern(strcat(folderlocation,'Run_',runname,'_Diffusion_Rxn_W1.txt'),Diffusion_W1);
WritePattern(strcat(folderlocation,'Run_',runname,'_Diffusion_Rxn_W2.txt'),Diffusion_W2);

WritePattern(strcat(folderlocation,'Run_',runname,'_Electrical_Circuit_W1.txt'),Electrical_W1);
WritePattern(strcat(folderlocation,'Run_',runname,'_Electrical_Circuit_W2.txt'),Electrical_W2);

WritePattern(strcat(folderlocation,'Run_',runname,'_Microfluidic_W1.txt'),Microfluidic_W1);
WritePattern(strcat(folderlocation,'Run_',runname,'_Microfluidic_W2.txt'),Microfluidic_W2);

WritePattern(strcat(folderlocation,'Run_',runname,'_Resonator_W1.txt'),Resonator_W1);
WritePattern(strcat(folderlocation,'Run_',runname,'_Resonator_W2.txt'),Resonator_W2);

%% 4. Merge patterns to create 2 drivers:

%p1 = PatternMerger(Actuator_W1,Diffusion_W1);
%plotPattern(Actuator_W1,'g',1);
%plotPattern(Diffusion_W1,'m',1);
%plotPattern(p1 + 50E-9,'k',2);
%p2 = PatternMerger(Electrical_W1,Microfluidic_W1);
%plotPattern(Electrical_W1,'g',1);
%plotPattern(Microfluidic_W1,'m',1);
%plotPattern(p2 + 50E-9,'k',2);
%p3 = PatternMerger(p1,Resonator_W1);
%plotPattern(p1,'g',1);
%plotPattern(Resonator_W1,'r',1);
%plotPattern(p3 + 50E-9,'k',2);
%p4 = PatternMerger(p3,p2);

Driver_W1 = MakeDriver(Actuator_W1,Diffusion_W1,Electrical_W1,Microfluidic_W1,Resonator_W1);
%plotPattern(Driver_W1,'r',1);
Driver_W1 = AlignPattern(Driver_W1);
%plotPattern(Driver_W1 + 50E-9,'k',2);
%figure(2);
Driver_W2 = MakeDriver(Actuator_W2,Diffusion_W2,Electrical_W2,Microfluidic_W2,Resonator_W2);
%plotPattern(Driver_W2,'g',1);
Driver_W2 = AlignPattern(Driver_W2);
%plotPattern(Driver_W2 + 50E-9,'k',2);

disp('Step 4: Drivers generated');

%% 5. Write drivers to disk.

WritePattern(strcat(folderlocation,'Run_',runname,'_DRIVER_W1.txt'),Driver_W1);
WritePattern(strcat(folderlocation,'Run_',runname,'_DRIVER_W2.txt'),Driver_W2);