// Gmsh project created on Fri Feb  14 2025
// Autor: Bruna B. T. Francisco
// Geometria do GEM com um único furo e com inclinação entorno do eixo central do furo

//+ Definindo criação de geometrias através de operações lógicas com volumes
SetFactory("OpenCASCADE");

//********************************************************************************
//+ Parâmetros de geometria
//********************************************************************************

//+ Distância entre os furos
Pitch = DefineNumber[ 0.160, Name "Parameters/Pitch" ];
//+ Espessura do dielétrico
ThickDiel = DefineNumber[ 0.05, Name "Parameters/ThickDiel" ];
//+ Espessura do condutor
ThickConduct = DefineNumber[ 0.005, Name "Parameters/ThickConduct" ];
//+ Raio do furo do dielétrico
RadiusDiel = DefineNumber[ 0.025, Name "Parameters/RadiusDiel" ];
//+ Raio do furo do condutor
RadiusConduct = DefineNumber[ 0.026, Name "Parameters/RadiusConduct" ];
//+ Diâmetro da cintura em furos bicônicos
RadiusWaist = DefineNumber[ 0.023, Name "Parameters/RadiusWaist" ];
//+ Altura relativa da cintura (0.5 é a metade da altura)
WaistHeight = DefineNumber[ 0.5, Name "Parameters/WaistHeight" ];
//+ Altura do volume de gás acima do GEM
DriftL = DefineNumber[ 0.2, Name "Parameters/DriftL" ];
//+ Altura do volume de gás abaixo do GEM
InductionL = DefineNumber[ 0.1, Name "Parameters/InductionL" ];
//Origem
Point(1) = {0,0,0};
//Angulos para rotação
Theta = DefineNumber[ 0.17, Name "Parameters/theta" ];
Phi   = DefineNumber[ 0.17, Name "Parameters/Phi" ];


//********************************************************************************
//+ Parâmetros de controle de malha
//********************************************************************************

Mesh.Algorithm = 6;
Mesh.MeshSizeMin = ThickConduct/5;
Mesh.MeshSizeMax = ThickConduct;

//********************************************************************************
//+ Criando a folha do dielétrico
//********************************************************************************

//+ Cria volume do dielétrico
Box(1) = {-Pitch*Sqrt(3)/2, -Pitch/2, -ThickDiel/2, Pitch*Sqrt(3), Pitch, ThickDiel}; 

//+ Furo 1 (centralizado em (0, 0, 0))
//Cone(2) = {0, 0, -ThickDiel/2-RadiusDiel*Sin(Theta), 0, 0, WaistHeight*ThickDiel+RadiusDiel*Sin(Theta), RadiusDiel, RadiusWaist, 2*Pi};
//Cone(3) = {0, 0, ThickDiel/2+RadiusDiel*Sin(Theta), 0, 0, (WaistHeight-1)*ThickDiel-RadiusDiel*Sin(Theta), RadiusDiel, RadiusWaist, 2*Pi};

// Cones ajustados para que não sobre uma parte de dielétrico acima e abaixo da base do cone
Cone(2) = {0, 0, -ThickDiel/2-(RadiusDiel-(ThickDiel/2)*Sin(Theta/2 ))*Cos(Theta), 0, 0, WaistHeight*ThickDiel+(RadiusDiel-(ThickDiel/2)*Sin(Theta/2 ))*Cos(Theta), RadiusDiel, RadiusWaist, 2*Pi};
Cone(3) = {0, 0, ThickDiel/2+(RadiusDiel-(ThickDiel/2)*Sin(Theta/2 ))*Cos(Theta), 0, 0, (WaistHeight-1)*ThickDiel-(RadiusDiel-(ThickDiel/2)*Sin(Theta/2 ))*Cos(Theta), RadiusDiel, RadiusWaist, 2*Pi};

Rotate { {1, 0, 0}, {0, 0, 0}, Theta } { Volume{2}; } // inclinação em x
Rotate { {1, 0, 0}, {0, 0, 0}, Theta } { Volume{3}; }
Rotate { {0, 0, 1}, {0, 0, 0}, Phi } { Volume{2}; Volume{3}; } //inclinação em z

//+ Operação lógica de criação do dielétrico com os furos
BooleanDifference(10) = { Volume{1}; Delete; }{ Volume{2}; Volume{3}; Delete; };


//********************************************************************************
//+ Criação do condutor superior do GEM
//********************************************************************************

//+ Cria filme condutor superior
Box(11) = {-Pitch*Sqrt(3)/2, -Pitch/2, ThickDiel/2, Pitch*Sqrt(3), Pitch, ThickConduct};

//+ Furo 1
Cylinder(12) = {0, -RadiusDiel*Sin(Theta), ThickDiel/2, 0, 0, ThickConduct, RadiusConduct, 2*Pi};
Rotate { {0, 0, 1}, {0, 0, 0}, Phi } { Volume{12}; }

//+ Operação lógica de criação do filme condutor superior com os furos
BooleanDifference(16) = { Volume{11}; Delete; }{ Volume{12}; Delete; };

//********************************************************************************
//+ Criação do condutor inferior do GEM
//********************************************************************************

//+ Cria filme condutor inferior
Box(17) = {-Pitch*Sqrt(3)/2, -Pitch/2, -ThickDiel/2, Pitch*Sqrt(3), Pitch, -ThickConduct};

//+ Furo 1
Cylinder(18) = {0, RadiusDiel*Sin(Theta), -ThickDiel/2, 0, 0, -ThickConduct, RadiusConduct, 2*Pi};
Rotate { {0, 0, 1}, {0, 0, 0}, Phi } { Volume{18}; }

//+ Operação lógica de criação do filme condutor inferior com os furos
BooleanDifference(22) = { Volume{17}; Delete; }{ Volume{18}; Delete; };

//********************************************************************************
//+ Criação do volume de gás para simulação do GEM
//********************************************************************************

//+ Cria volume do gás
Box(23) = {-Pitch*Sqrt(3)/2, -Pitch/2, -InductionL-ThickDiel/2-ThickConduct, Pitch*Sqrt(3), Pitch, DriftL+InductionL+ThickDiel+2*ThickConduct};
//+ Operação lógica que remove os objetos do volume de gás
BooleanDifference(24) = { Volume{23}; Delete; }{ Volume{10}; Volume{16}; Volume{22}; };
//+

//********************************************************************************
//+ Elimina superposição
//********************************************************************************

Coherence;

//********************************************************************************
//+ Criação dos objetos físicos
//********************************************************************************
epsilon = DefineNumber[ 1e-6, Name "Parameters/epsilon" ];

//+ Criando Superfícies físicas do eletrodo inferior
surf_dw() = Surface In BoundingBox{  -Pitch*Sqrt(3)/2-epsilon, -Pitch/2 -epsilon, -InductionL-ThickDiel/2-ThickConduct-epsilon, Pitch*Sqrt(3)/2+epsilon, Pitch+epsilon, -InductionL-ThickDiel/2-ThickConduct+epsilon};
Physical Surface(1) = {surf_dw()};

//+ Criando Superfícies físicas do eletrodo superior
surf_up() = Surface In BoundingBox{  -Pitch*Sqrt(3)/2-epsilon, -Pitch/2 -epsilon, DriftL+ThickDiel/2+ThickConduct-epsilon, Pitch*Sqrt(3)/2+epsilon, Pitch+epsilon, DriftL+ThickDiel/2+ThickConduct+epsilon};
Physical Surface(2) = {surf_up()};

//+ Laterias do volume total
surf_t() = Surface In BoundingBox{  -Pitch*Sqrt(3)/2-epsilon, -Pitch/2 - epsilon, -InductionL-ThickDiel/2-ThickConduct-epsilon, Pitch*Sqrt(3)/2+epsilon, -Pitch/2 + epsilon, DriftL+InductionL+ThickDiel+2*ThickConduct+epsilon};
Physical Surface(3) = {surf_t()};

surf_f() = Surface In BoundingBox{  -Pitch*Sqrt(3)/2-epsilon, Pitch/2 - epsilon, -InductionL-ThickDiel/2-ThickConduct-epsilon, Pitch*Sqrt(3)/2+epsilon, Pitch/2 + epsilon, DriftL+InductionL+ThickDiel+2*ThickConduct+epsilon};
Physical Surface(4) = {surf_f()};

surf_e() = Surface In BoundingBox{  -Pitch*Sqrt(3)/2-epsilon, -Pitch/2-epsilon, -InductionL-ThickDiel/2-ThickConduct-epsilon, -Pitch*Sqrt(3)/2+epsilon, Pitch/2+epsilon, DriftL+InductionL+ThickDiel+2*ThickConduct+epsilon};
Physical Surface(5) = {surf_e()};

surf_d() = Surface In BoundingBox{  Pitch*Sqrt(3)/2-epsilon, -Pitch/2 - epsilon, -InductionL-ThickDiel/2-ThickConduct-epsilon, Pitch*Sqrt(3)/2+epsilon, Pitch/2+epsilon, DriftL+InductionL+ThickDiel+2*ThickConduct+epsilon};
Physical Surface(6) = {surf_d()};

//+ Superfícies dos condutores superior do GEM
top_cond() = Abs(Boundary {Volume{16};});
Physical Surface(7) = {top_cond()};

//+ Superfícies dos condutores inferior do GEM
bot_cond() = Abs(Boundary {Volume{22};});
Physical Surface(8) = {bot_cond()};

//+ Criando volumes físicos
//+ Dielétrico
Physical Volume(1) = {10};
//+ Condutores
Physical Volume(2) = {16, 22};
//+ Volume do gás
Physical Volume(3) = {24};
