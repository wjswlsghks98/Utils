function isInside = isPointBetween(O, P1, P2, P)
    % Inputs:
    % O:  Center of the circle [x, y]
    % P1: First endpoint of the arc [x, y]
    % P2: Second endpoint of the arc [x, y]
    % P:  Test point [x, y]

    % Compute vectors
    OP1 = P1 - O;  % Vector OP1
    OP2 = P2 - O;  % Vector OP2
    OP = P - O;    % Vector OP

    % Compute 2D cross products
    cross1 = OP1(1) * OP(2) - OP1(2) * OP(1);  % OP1 x OP
    cross2 = OP2(1) * OP(2) - OP2(2) * OP(1);  % OP2 x OP

    % Ensure consistency for clockwise or counterclockwise arcs
    isInside = (cross1 >= 0 && cross2 <= 0) || (cross1 <= 0 && cross2 >= 0);
end

