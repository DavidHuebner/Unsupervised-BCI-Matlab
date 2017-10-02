function letter = convert_position_to_letter( pos )
% Converts a position in a matrix to the corresponding letter using the
% following matrix configuration:
%
%     A  B 	# 	C 	# 	D 	E
%     #  F 	G 	H 	I 	J 	#
%     K  L 	M 	# 	N 	O 	P
%     Q  # 	R 	S 	T 	U 	#
%     V  W 	X 	Y 	# 	Z 	␣
%     #  . 	# 	, 	! 	? 	<-
A = ['a','b','#','c','#','d','e','#','f','g','h','i','j','#','k','l','m',...
    '#','n','o','p','q','#','r','s','t','u','#','v','w','x','y','#','z',...
    ' ','#','.','#',',','!','?','<'];         
    
letter = A(pos);
end

