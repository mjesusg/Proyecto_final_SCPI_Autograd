% EJEMPLO DE OPTIMIZACION BASADA EN PROBLEMAS UTILIZANDO AUTOGRAD.

% Se tomara como ejemplo la funcion:f(x, y) = 100 (y-x^2)^2 + (1-x)^2 , la
% cual se desea miimizar, utilizando el disco unitario x^2 + y^2 <= 1

%Primero se crean las variables de optimizacion.

x = optimvar('x');
y = optimvar('y');

%Luego, crea expresiones de optimización utilizando estas variables.

fun = 100*(y - x^2)^2 + (1 - x)^2;
unitdisk = x^2 + y^2 <= 1;

%Se crea un problema de optimización con estas expresiones en los 
% campos apropiados del problema.

prob = optimproblem("Objective",fun,"Constraints",unitdisk);

% Se resuelve el problema llamando a resolver , comenzando desde x = 0, y = 0.

x0.x = 0;
x0.y = 0;
sol = solve(prob,x0);
disp(sol)

%La funcion solve usa AD para acelerar el proceso de solución.

%Para entender el proceso de solucion con mas detalle se traza el logaritmo 
% de uno más la función objetivo en el disco unitario y se traza un 
% círculo rojo en la solución.

figure(1)
[R,TH] = ndgrid(linspace(0,1,100),linspace(0,2*pi,200));
[X,Y] = pol2cart(TH,R);
surf(X,Y,log(1+100*(Y - X.^2).^2 + (1 - X).^2),'EdgeColor','none')
colorbar
view(0,90)
axis equal
hold on
plot3(sol.x,sol.y,1,'ro','MarkerSize',10)
hold off


%EFECTO DE LA DIFERENCIACION AUTOMATICA.

%Para conocer el efacto de la diferenciacion automatica se examina el
%probelam con mas detalle, solicitando más salidas de solución: número 
% de iteraciones y evaluaciones de funciones que realiza el solucionador.

[sol,fval,exitflag,output] = solve(prob,x0);
fprintf('fmincon takes %g iterations and %g function evaluations.\n',...
    output.iterations,output.funcCount)

%fmincon es una minimización general restringida  que llama a otros 
% solucionadores especializados.

%La estructura de salida muestra que el solucionador toma 24 iteraciones 
% y 34 recuentos de funciones.

%Para notar la importancia de AD, se ejecuta el problema nuevamente, esta 
% vez imponiendo que el solucionador no utilice AD.

figure(2)
[sol2,fval2,exitflag2,output2] = solve(prob,x0,...
    'ObjectiveDerivative',"finite-differences",'ConstraintDerivative',"finite-differences");
fprintf('fmincon takes %g iterations and %g function evaluations.\n',...
    output2.iterations,output2.funcCount)
plot([1 2],[output.funcCount output2.funcCount],'r-',...
    [1 2],[output.funcCount output2.funcCount],'ro')
ylabel('Numero de evaluaciones de funciones')
xlim([0.8 2.2])
ylim([0 90])
legend('Recuento de funciones (Mas bajo es mejor)','Location','northwest')
ax = gca;
ax.XTick = [1,2];
ax.XTickLabel = {'Con AD','Sin AD'};

%Esta vez, el solucionador toma 84 funciones, no 34. La razón de esta 
% diferencia es la diferenciación automática.

%Las soluciones son casi las mismas con o sin AD

fprintf('The norm of solution differences is %g.\n',norm([sol.x,sol.y] - [sol2.x,sol2.y]))
