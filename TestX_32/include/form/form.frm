HTTP/1.1 201 Ok
Server: AntX/0.72 + WebTester 1.01 x324
Date:   GMT
Content-Type: text/html
Content-Length:  
Connection:  keep-alive

 <!DOCTYPE html>
<html>
<head><title>ПЗЗ ЦПРП «Тестер»</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<link rel="stylesheet" href="css/ test.css" type="text/css">
<link rel="shortcut icon" href="Img/app.ico">
 
<script language="JavaScript">
 var Session = ' function Get()
{
	Ask.Post.name = ' cx';
	Ask.Post.value = User.value;
	Ask.submit();
}
</script>
</head>
 
<body>
<table class="OrgName">
<tr>
	<th class="MainName" colspan=2><br>АТ «УКРАЇНСЬКА ЗАЛІЗНИЦЯ»</th>
</tr>
<tr>
	<th class="MainName" colspan=2>РФ «Південно-західна залізниця»</th>
</tr>
<tr>
	<th class="MainName" colspan=2>Відокремлений підрозділ</th>
</tr>
<tr>
	<th colspan=2>Центр професійного розвитку персоналу</th>
</tr> 
<tr>
	<td class="LeftLable"><b>Admin</b></td>
	<td class="RightLable">[<i>Оператор</i>]</td>
</tr>	
</table>

<br><table align="center">
<tr>
	<td class="ErrTest" colspan=2> </td>
	<td rowspan=2><img class="Key" src="Img/psw.png" onclick="javascript:Get();"></td>
</tr>
<tr>
	<td><input class="GetTest" type="password" id="User" style="width:160px;"></td>
</tr>
</table> 
</table>

<br><table align="center">
<tr>
	<td class="GetTest" colspan=2> </td>
	<td rowspan=2><img class="Key" src="Img/test.png" onclick="javascript:Get();"></td>
</tr>
<tr>
	<td><input class="GetTest" type="text" id="User" style="width:200px;"></td>
</tr>
</table> 

<form name="Ask" action="test.php" enctype="application/x-www-form-urlencoded" method="post">
	<input type="hidden" id="Post">
</form> 

<table class="Footer">
<tr>
	<td>&copy;Ruslan FoXx, Kyiv 2019-20    WebTester 1.01b (x32)</td>
</tr>
</table>
</body></html>
 ';

function Get()
{
	if( TestName.value != " ")
	{
		Ask.Post.name = 'tc';
		Ask.Post.value = Session + '.' + TestName.value;
		Ask.submit();
}	}

function Back()
{
	Ask.Post.name = 'tl';
	Ask.Post.value = Session;
	Ask.submit();
}
</script>
</head>

<!-- Test::Import --> 
<tr>
	<td class="LeftLable"><b>Бібліотека</b></td>
	<td class="RightButton"><input class="GetMode" type="button" value="Тести" onclick="javascript:Back();"></td>
</tr>
</table>
<br>
<table class="Browse">
<tr>
	<th>№</th><th>Назва</th><th>Файл</th><th>Розмір</th>
</tr> 
<tr class="Item" onclick="javascript:TestName.value=' ';">
	<td> .</td><td align="left"> </td>
	<td align="left"> </td><td><i> </i></td>
</tr> 
<tr class="ItemErr">
	<td> ??? 
<tr class="Item">
	<td align="center" colspan=4>Тести не знайдені!</td>
</tr> 
</table>

<br><table class="Focus">
<tr>
	<td><input class="Control" type="button" value=" " id="TestName" onclick="javascript:Get();"></td>
</tr>
</table> ';

function Get( param )
{
	Ask.Post.name = 'tv';
	Ask.Post.value = Session + '.' + param;
	Ask.submit();
}

function Add()
{
	Ask.Post.name = 'tg';
	Ask.Post.value = Session;
	Ask.submit();
}
</script>
</head>

<!-- Test::List --> 
<tr>
	<td class="LeftLable"><b>Тести</b></td> 
	<td class="RightButton"><input class="GetMode" type="button" value="+" onclick="javascript:Add();"></td> 
</tr>
</table>
<br>
<table class="Browse">
<tr>
	<th>№</th><th>Тест</th><th>Назва</th><th>Тест</th><th>Час</th><th>Питання</th><th>Меню</th>
</tr> 
<tr class="Item" onclick="javascript:Get(' ');">
	<td> .</td><td align="left"> </td>
	<td align="left"><i> </i></td><td> </td><td> </td>
</tr> 
</td>
	<td align="left" colspan=5>???</td>
</tr> 
<tr class="Item">
	<td align="center" colspan=7>Тести відсутні!</td>
</tr> 
</table> ';
var LevelChecked = 0;

function Get( param )
{
	Ask.Post.name = 'tx';
	Ask.Post.value = Session + '.' + param;
	Ask.submit();
}

function Set( param )
{
	Ask.Post.name = param;
	Ask.Post.value = Session;
	Ask.submit();
}
</script>
</head>

<!-- Test::View --> 
<tr>
	<td class="LeftLable"><b> </b></td>
	<td class="RightButton"><input class="GetMode" type="button" value="Перегляд" onclick="javascript:Set('tl');"></td>
</tr>
</table>

<table class="Panel">
<tr onclick="javascript:Set('ts');"> 
	<td class="Score "> </td> 
</tr>
</table>

<table class="Panel">
<tr>
	<td class="LeftLable"> <br><i> </i></td>
	<td class="RightLable"><b> </b>:   з  )</td>
</tr>
</table>
 
<table class="Panel">
	<tr class="Focus" onclick="javascript:Get( );">
	<td class="GetQuest"><b> </b>  </td></tr> 
	<tr><td class="Ans "> </td></tr> 
</table> 
<br>
<table class="Focus">
<tr> 
	<td><input class="Control" type="button" value="Файл" onclick="javascript:Set('tf');"></td> 
	<td><input class="Control" type="button" value="Друк" onclick="javascript:Set('pt');"></td>
</tr>
</table> ';
var Checked =  ;
var SetImgSelectedOn = new Image();
var SetImgSelectedOff = new Image();

function Get( param )
{
	Ask.Post.name = 'tx';
	Ask.Post.value = Session + '.' + param + '. .' + Checked;
	Ask.submit();
}

function Set( param )
{
	if( Checked & param )
	{
		Checked &= ~param;
		document.getElementById('Item' + param ).src = SetImgSelectedOff.src;
	}
	else
	{
		Checked |= param;
		document.getElementById('Item' + param ).src = SetImgSelectedOn.src;
}	}

function Back()
{
	Ask.Post.name = 'tv';
	Ask.Post.value = Session;
	Ask.submit();
}

function Init()
{
	var ind =  ;
	var Scan = 1;

	SetImgSelectedOn.src = "Img/1.png";
	SetImgSelectedOff.src = "Img/0.png";

	while( ind--)
	{
		if( Checked & Scan ) document.getElementById('Item' + Scan ).src = SetImgSelectedOn.src;
		else document.getElementById('Item' + Scan ).src = SetImgSelectedOff.src;
		Scan <<= 1;
}	}
</script>
</head>

<!-- Test::Edit --> 
<tr>
	<td class="LeftLable"><b> </b></td>
	<td class="TimeLable"> </td>
</tr>
</table>

<table class="Panel">
<tr> 
	<td class="Select Text Quest " onclick="javascript:Get( );"> </td> 
</tr>
</table>

<table class="Panel">
<tr>
	<td class="RightLable"><b> </b>:   з  </td>
</tr>
</table>

<p class="QuestText"><b> .</b>  <i> ( )</i></p>
<table class="Focus">
 <tr>
	<td class="Item" onclick="javascript:Set( );">
	<img id="Item " alt="+">&nbsp; </td>
</tr> 
</table><script language="JavaScript">Init();</script>
<br>
<table class="Focus">
<tr>
	<td align="left"><input class="Control" type="button" value="<< Попередній" onclick="javascript:Get( );"></td>
	<td align="center"><input class="Control" type="button" value="Перегляд" onclick="javascript:Back();"></td>
	<td align="right"><input class="Control" type="button" value="Наступний >>" onclick="javascript:Get( );"></td>
</tr>
</table> ';
var LevelHigh =  ;
var LevelLow =  ;
var LevelChecked = 0;
var LevelCount;
var Post, Score, ind;

function Get( param )
{
	if( LevelChecked )
	{
		LevelLow = param;
		LevelChecked = 0;
		Mode.className = 'ScoreC';
		Mode.innerText = "Високий";
	}
	else
	{
		LevelHigh = param;
		LevelChecked = 1;
		Mode.className = 'ScoreB';
		Mode.innerText = "Середній";
	}

	LevelCount = 1;
	ind = 10;

	while( ind--)
	{
		Score = parseInt( document.getElementById('Scale' + LevelCount ).value );
		if( Score >   || !Score ) break;
		LevelCount++;
 	}

	if( LevelLow > LevelHigh ) LevelLow = LevelHigh;
	if( LevelHigh > LevelCount ) LevelHigh = LevelCount;
	ind = 1;
	
	while( LevelLow > ind )
	{
		document.getElementById('Score' + ind ).className = "ScoreA";
		ind++
 	}
	while( LevelHigh > ind )
	{
		document.getElementById('Score' + ind ).className = "ScoreB";
		ind++
 	}
	while( LevelCount > ind )
	{
		document.getElementById('Score' + ind ).className = "ScoreC";
		ind++
 	}
	while( 10 >= ind )
	{
		document.getElementById('Score' + ind ).className = "Score";
		ind++
}	}

function Set()
{
	Post = Test.value + '.' + Time.value + '.' + (( LevelHigh << 4 )| LevelLow ) + '.';
	LevelCount = 1;
	ind = 10;

	while( ind--)
	{
		Score = parseInt( document.getElementById('Scale' + LevelCount ).value );
		if(!Score ) break;
		Post += Score + '-';
		LevelCount++;
	}
	Ask.Post.name = 'ts';
	Ask.Post.value = Session + '.' + Post;
	Ask.submit();
}

function Back()
{
	Ask.Post.name = 'tv';
	Ask.Post.value = Session;
	Ask.submit();
}
</script>
</head>

<!-- Test::Set --> 
<tr>
	<td class="LeftLable"><b> </b></td>
	<td class="RightButton"><input class="GetMode" type="button" value="Перегляд" onclick="javascript:Back();"></td>
</tr>
</table>

<table class="Panel">
<tr>
 	<td class="Score " id="Score " onclick="javascript:Get( );"> </td>
 </tr>
<tr>
 	<td class="Score"><input class="Scale" type="text" value=  id="Scale "></td>
 </tr>
</table>

<table class="Panel">
<tr>
	<td class="LeftLable">Попередній рівень [<b> </b>]</td>
	<td class="RightLable"><b> </b></td>
</tr>
</table>

<table class="Browse">
<tr>
	<th>Рівень</th><th>Тести</th><th>Час</th>
</tr>
<tr>
	<td class="ScoreC" id="Mode"></td>
	<td class="Score"><input class="Scale" type="text" value=  id="Test"></td>
	<td class="Score"><input class="Scale" type="text" value=  id="Time"></td>
</tr>
</table>
<br>
<table class="Focus">
<tr>
	<td><input class="Control" type="button" id="GetPost" value="Застосувати" onclick="javascript:Set();"></td>
</tr>
</table> ';

function Get()
{
	if( FileName.value != " ")
	{
		Ask.Post.name = 'gc';
		Ask.Post.value = Session + '.' + FileName.value;
		Ask.submit();
}	}

function Back()
{
	Ask.Post.name = 'gl';
	Ask.Post.value = Session;
	Ask.submit();
}
</script>
</head>

<!-- Group::Import --> 
<tr>
	<td class="LeftLable"><b>Списки</b></td>
	<td class="RightButton"><input class="GetMode" type="button" value="Групи" onclick="javascript:Back();"></td>
</tr>
</table>
<br>
<table class="Browse">
<tr>
	<th>№</th><th>Назва</th><th>Файл</th><th>Розмір</th>
</tr> 
<tr class="Item" onclick="javascript:FileName.value=' ';">
	<td> .</td><td align="left"> </td>
	<td align="left"> </td><td><i> </i></td>
</tr> 
<tr class="ItemErr">
	<td> ??? 
<tr class="Item">
	<td align="center" colspan=4>Списки не знайдені!</td>
</tr> 
</table>

<br><table class="Focus">
<tr>
	<td><input class="Control" type="button" id="FileName" value=" " onclick="javascript:Get();"></td>
</tr>
</table> ';

function Get( param )
{
	Ask.Post.name = 'bl';
	Ask.Post.value = Session + '.' + param;
	Ask.submit();
}

function Sel( param )
{
	Ask.Post.name = 'gl';
	Ask.Post.value = Session + '.' + param;
	Ask.submit();
} 

function Add()
{
	Ask.Post.name = 'gg';
	Ask.Post.value = Session;
	Ask.submit();
} 
</script>
</head>

<!-- Group::List --> 
<tr>
	<td class="LeftLable"><b>Групи</b></td> 
	<td class="RightButton"><input class="GetMode" type="button" value="+" onclick="javascript:Add();"></td> 
</tr>
</table>

<table class="Panel">
<tr> 
	<td class="Select " onclick="javascript:Sel(' ');">20 </td> 
</tr>
</table>
<br>
<table class="Browse">
<tr>
	<td>№</td><td>Група</td><td>Склад</td><td>Дата</td>
</tr> 
<tr class="Item" onclick="javascript:Get( );">
	<td> .</td><td align="left"> </td><td> </td><td> </td>
</tr> 
<tr class="ItemErr">
	<td> .</td><td align="left">???</td><td>0</td><td> </td>
</tr> 
<tr class="ItemSep">
	<td align="center" colspan=4> </td>
</tr> Січень Лютий Березень Квітень Травень Червень Липень Серпень Вересень Жовтень Листопад Грудень 
<tr class="Item">
	<td align="center" colspan=4>Груп не знайдено!</td>
</tr> 
</table> function Get()
{
	Ask.Post.name = 'cx';
	Ask.Post.value = Client.value;
	Ask.submit();
}
</script>
</head>

<!-- Table::Group --> 
<tr>
	<td class="LeftLable"><i> </i><br><b> </b></td>
	<td class="RightLable">Питань <b> </b></td>
</tr>
</table>

<table class="Panel">
<tr>
	<td class="LeftLable"><i> </i><br><b> </b></td>
	<td class="RightLable"> <br><i> </i></td>
</tr>
</table>

<table align="center">
<tr>
	<td class="GetTest" colspan=2> </td>
	<td rowspan=2>
		<img class="Key" src="Img/test.png" onclick="javascript:Get();">
	</td>
</tr>
<tr>
	<td>
	<select class="GetName" id="Client">
 		<option value=" "> </option>
 </select>
	</td>
</tr>
</table> ';

function Add()
{
	var Sel = '.' + TestName.value + '.';
	var ind = 0;
	var count = 0;

	while( ind <   )
	{
		ind++;
		if( document.getElementById('UsrItem' + ind ).checked )
		{
			Sel += ind + '-'; 
			count++;
	}	}

	if( count )
	{
		Ask.Post.name = 'bc';
		Ask.Post.value = Session + Sel;
		Ask.submit();
}	}

function Back()
{
	Ask.Post.name = 'bl';
	Ask.Post.value = Session;
	Ask.submit();
}
</script>
</head>

<!-- Table::Get --> 
<tr>
	<td class="LeftLable"><i> </i><br><b> </b></td>
	<td class="RightButton"><input class="GetMode" type="button" value="Група" onclick="javascript:Back();"></td>
</tr>
</table>

<br><select class="TestSelect" name="TestName" id="TestName">
 	<option value=" "> </option>
 </select>

<table class="Browse">
<tr>
	<th>№</th><th>Тест</th><th>+</th>
</tr> 
<tr class="Item" align="center">
	<td> .</td><td align="left"> </td>
	<td><input type="checkbox" name="UsrItem" id="UsrItem " checked></td>
</tr> 
</table>

<br><table class="Focus">
<tr>
	<td><input class="Control" type="button" value="Додати завдання" onclick="javascript:Add();"></td>
</tr>
</table> 
<tr class="Item">
<td align="center" colspan=3>Список пустий</td></tr>
 ';

function Get( param )
{
	Ask.Post.name = 'bv';
	Ask.Post.value = Session + '.' + param;
	Ask.submit();
}

function Set( param )
{
	Ask.Post.name = 'sv';
	Ask.Post.value = Session + '.' + param;
	Ask.submit();
}
 
function Add()
{
	Ask.Post.name = 'bg';
	Ask.Post.value = Session + '. ';
	Ask.submit();
}
 
function Back()
{
	Ask.Post.name = 'gl';
	Ask.Post.value = Session;
	Ask.submit();
}

function Type()
{
	Ask.Post.name = 'pg';
	Ask.Post.value = Session + '. ';
	Ask.submit();
}
</script>
</head>

<!-- Table::List --> 
<tr><td class="LeftLable"><i> </i><br><b> </b></td>
	<td class="RightButton"><input class="GetMode" type="button" value="Групи" onclick="javascript:Back();">
	</td>
</tr>
</table>

<table class="Panel">
<tr>
	<td class="LeftLable">Склад <b> </b></td>
	<td class="RightLable"> <br><i> </i></td>
</tr>
</table>

<table class="Browse">
<tr>
	<th>Id</th><th>Завдання</th><th>Тести</th><th>Дата</th><th>Стан</th>
</tr> 
<tr class="Item" onclick="javascript: );">
	<td> </td><td align="left"><i> </i></td>
	<td> </td><td> </td>
</tr> 
</table>

<br><table class="Focus">
<tr> 
 	<td><input class="Control" type="button" value="Завдання" onclick="javascript:Add();"></td>
 	<td><input class="Control" type="button" value="Друк списку" onclick="javascript:Type();"></td>
</tr>
</table> 
<tr class="Item">
	<td align="center" colspan=5>Завдання не знайдені</td>
</tr> ';
var NumGroup = Session + '. ';

function Get( param )
{
	Ask.Post.name = 'bx';
	Ask.Post.value = NumGroup + '.' + param;
	Ask.submit();
}

function Update()
{
	Ask.Post.name = 'bv';
	Ask.Post.value = NumGroup;
	Ask.submit();
}

function Back()
{
	Ask.Post.name = 'bl';
	Ask.Post.value = Session + '. ';
	Ask.submit();
}

function Set( param )
{
	Ask.Post.name = param;
	Ask.Post.value = NumGroup;
	Ask.submit();
}
</script>
</head>

<!-- Table::View --> 
<tr>
	<td class="LeftLable"><i> </i><br><b> </b></td>
	<td class="RightButton"><input class="GetMode" type="button" value="Тести" onclick="javascript:Back();"></td>
</tr>
</table>

<table class="Panel">
<tr>
	<td class="LeftLable"><i> </i><br><b> </b></td>
	<td class="RightLable"> <br><i> </i></td>
</tr>
</table>

<table class="Browse">
<tr onclick="javascript:Update();">
	<th>№</th><th>П.І.Б.</th><th>Тест</th><th>Питання</th><th>Час</th><th>Завершено</th><th>Результат</th><th>Оцінка</th>
</tr> 
<tr class="Item" onclick="javascript:Get(' ');">
	<td><i> .</i></td><td align="left"> </td>
	<td><i> </i></td><td> .<b> </b></td><td><i> </i></td> 
	<td>&nbsp;</td><td>&nbsp; </td><td>&nbsp;</td>
</tr> 
	<td> &nbsp;<img src="Img/t.png"><td> 
	<td> </td><td> %</td><td><b> </b></td>
</tr> 
</table>

<script language="JavaScript">setTimeout('Update();', 16000 );
</script>

<br><table class="Focus">
<tr> 
	<td><input class="Control" type="button" value="Створити архів" onclick="javascript:Set('sc');"></td> 
	<td><input class="Control" type="button" value="Друк кодів" onclick="javascript:Set('px');"></td>
	<td><input class="Control" type="button" value="Друк результатів" onclick="javascript:Set('pz');"></td>
</tr>
</table> 
<tr class="Item">
	<td align="center" colspan=9>Завдання відсутні</td>
</tr> ';
var NumGroup = Session + '. ';

function Get( param )
{
	Ask.Post.name = 'sx';
	Ask.Post.value = NumGroup + '.' + param;
	Ask.submit();
}

function Back()
{
	Ask.Post.name = 'bl';
	Ask.Post.value = Session + '. ';
	Ask.submit();
}

function Set( param )
{
	Ask.Post.name = param;
	Ask.Post.value = NumGroup;
	Ask.submit();
}
</script>
</head>

<!-- Store::View --> 
</table>
<br>
<table class="Focus">
<tr> 
	<td><input class="Control" type="button" value="Відновити базу" onclick="javascript:Set('sz');"></td> 
	<td><input class="Control" type="button" value="Друк результатів" onclick="javascript:Set('ps');"></td>
</tr>
</table> var ViewerInterval;
var WaitTime =  ;

function TimeClose()
{
	if(!WaitTime--) clearInterval( ViewerInterval );

	var TimeMin = Math.floor( WaitTime / 60 ) + ':'; 
	var TimeSec = WaitTime % 60;
		
	if ( TimeSec < 10 ) TimeMin += '0';

	TimeOut.innerText = TimeMin + TimeSec;
} 

function Get( param )
{
	Ask.Post.name = ' bx';
	Ask.Post.value = Session + '. .' + param;
	Ask.submit();
}

function Back()
{
	Ask.Post.name = ' bv';
	Ask.Post.value = Session;
	Ask.submit();
}
</script>
</head>

<!-- Client::View --> 
<tr>
	<td class="LeftLable"><i> </i><br><b> </b></td>
	<td class="TimeLable" id="TimeOut"></td>
</tr>
</table>

<table class="Panel">
<tr> 
	<td class="Select " onclick="javascript:Get( );"> </td> 
</tr>
</table>

<table class="Panel">
<tr>
	<td class="LeftLable"><b> </b>% (<b> </b> +  ) рівень <b> </b></td>
	<td class="RightLable"><b> </b> [  з  </td>
</tr>
</table>

<p class="QuestText"><b> .</b>  <i> ( )</i></p>
<table class="Panel">
 <tr>
	<td class="Item "> </td>
</tr> 
</table> 
<script language="JavaScript">
	TimeClose();
	ViewerInterval = setInterval('TimeClose();', 999 );
</script> 
<br>
<table class="Focus">
<tr>
	<td align="left"><input class="Control" type="button" value="<< Попередній" onclick="javascript:Get( );"></td>
	<td align="center"><input class="Control" type="button" value="< Група >" onclick="javascript:Back();"></td>
	<td align="right"><input class="Control" type="button" value="Наступний >>" onclick="javascript:Get( );"></td>
</tr>
</table> var TimerInterval;
var WaitTime =  ;
var Checked =  ;
var SetImgSelectedOn = new Image();
var SetImgSelectedOff = new Image();

function Get( param )
{
	if(!param ) clearInterval( TimerInterval );

	Ask.Post.name = 'cx';
	Ask.Post.value = ' .' + param + '. .' + Checked;
	Ask.submit();
}

function TimeClose()
{
	if(!WaitTime--){ Get(0); return 0; }

	var TimeMin = Math.floor( WaitTime / 60 ) + ':'; 
	var TimeSec = WaitTime % 60;
		
	if ( TimeSec < 10 ) TimeMin += '0';

	TimeOut.innerText = TimeMin + TimeSec;
}

function Init()
{
	var ind =  ;
	var Scan = 1;

	SetImgSelectedOn.src = "Img/1.png";
	SetImgSelectedOff.src = "Img/0.png";

	while( ind--)
	{
		if( Checked & Scan ) document.getElementById('Item' + Scan ).src = SetImgSelectedOn.src;
		else document.getElementById('Item' + Scan ).src = SetImgSelectedOff.src;
		Scan <<= 1;
	}
	TimeClose();
}

function Set( param )
{
	 if( Checked ) document.getElementById('Item' + Checked ).src = SetImgSelectedOff.src;
	document.getElementById('Item' + param ).src = SetImgSelectedOn.src;
	Checked = param;
} if( Checked & param )
	{
		Checked &= ~param;
		document.getElementById('Item' + param ).src = SetImgSelectedOff.src;
	}
	else
	{
		Checked |= param;
		document.getElementById('Item' + param ).src = SetImgSelectedOn.src;
}	} 
</script>
</head>

<!-- Client::Get --> 
<tr>
	<td class="LeftLable"><i> </i><br><b> </b></td>
	<td class="TimeLable" id="TimeOut"></td>
</tr>
</table>

<table class="Panel">
<tr> 
	<td class="Select " onclick="javascript:Get( );"> </td> 
</tr>
</table>

<table class="Panel">
<tr>
	<td class="RightLable"><b> </b>:   з  </td>
</tr>
</table>

<p class="QuestText"><b> .</b>  <i> ( )</i></p>
<table class="Focus">
 <tr>
	<td class="Item" onclick="javascript:Set( );">
	<img id="Item " alt="+">&nbsp; </td>
</tr> 
</table>

<script language="JavaScript">
	Init();
	TimerInterval = setInterval('TimeClose();', 999 );
</script>
<br>
<table class="Focus">
<tr>
	<td align="left"><input class="Control" type="button" value="<< Попередній" onclick="javascript:Get( );"></td>
	<td align="center"><input class="Control" type="button" value="< Завершити >" onclick="javascript:if( confirm('Завершити тест?')) Get(0);"></td>
	<td align="right"><input class="Control" type="button" value="Наступний >>" onclick="javascript:Get( );"></td>
</tr>
</table> clearInterval( TimerInterval );
</script>
</head>

<!-- Client::End --> 
<tr>
	<td class="LeftLable"><i> </i><br><b> </b></td>
</tr>
</table>

<table class="Panel">
<tr> 
	<td class="Select Text Check False "> </td> 
</tr>
</table>

<table class="Panel">
<tr>
	<td class="LeftLable"><b> </b>%</td>
	<td class="RightLable"><b> </b>:   з  </td>
</tr>
</table>

<table class="Panel">
<tr>
	<td class="Score </td>
</tr>
</table>
<br>
<table class="Focus">
<tr>
	<td align="center"><input type="button" class="Control" value="< Вихід >" onclick="location.replace('test.php');"></td>
</tr>
</table> <tr>
	<td class="LableLeft"><i> </i><br><b> </b></td>
	<td class="LableRight"> <br><i> </i></td>
</tr>
</table>

<table class="Panel">
<tr>
	<td class="LableLeft"><i> </i><br><b> </b></td>
	<td class="LableRight">[ ]</td>
</tr>
</table>

<table class="List">
<tr align="center">
	<th>№</th><th>П.І.Б.</th><th>Тест</th> <th>Питання</th><th>Завершено</th><th>Результат</th><th>Оцінка</th> 
</tr> 
<tr class="Item" align="center">
	<td><i> .</i></td><td align="left"> </td><td><b> </b></td>
</tr> 
<tr class="Item" align="center">
	<td><i> .</i></td><td align="left"> </td>
	<td> </td><td> /<b> </b></td><td> <br> </td><td> %</td><td><b> </b></td>
</tr> 
</table>
</body></html>
 <tr class="Item">
	<td align="center" colspan=3>Завдання відсутні</td>
</tr> 
<tr class="Item">
	<td align="center" colspan=7>Результати відсутні</td>
</tr> <tr>
	<td class="LableLeft"><i> </i><br><b> </b></td>
	<td class="LableRight"> <br><i> </i></td>
</tr>
</table>
<table class="Panel">
<tr>
	<td class="LableLeft"><b>Список</b> (<i> </i>)</td>
</tr>
</table>

<table class="List">
<tr align="center">
	<th>№</th><th>П.І.Б.</th>
</tr> 
<tr class="Item" align="center">
	<td><i> .</i></td><td align="left"> </td>
</tr> 
</table>
</body></html>
 <tr>
	<td class="LableLeft"><b> </b></td>
</tr>
</table>

<table class="Panel">
<tr>
	<td class="LableLeft"> <br><i> </i></td>
	<td class="LableRight"><b> </b>:  )</td>
</tr>
</table>
 
<table class="List">
<tr>
	<td class="Item" align="left"><b> </b>  </td>
</tr>
</table>
 <p class="Answer"><i> </i></p>
 <p class="Answer"><b> </b></p>
 
</body></html>
 Виберіть користувача Введіть номер тесту Тест завершено! Тест не знайдено! Відомості відсутні Відмовлено!