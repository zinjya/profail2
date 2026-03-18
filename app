<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<title>チェス（AI対戦）</title>
<style>
body {
  display:flex;
  flex-direction:column;
  align-items:center;
  background:#222;
  color:white;
  font-family:sans-serif;
}
.board {
  display:grid;
  grid-template-columns:repeat(8,70px);
}
.cell {
  width:70px;height:70px;
  display:flex;
  align-items:center;
  justify-content:center;
  font-size:40px;
  cursor:pointer;
}
.white {background:#f0d9b5;}
.black {background:#b58863;}
.selected {outline:3px solid red;}
</style>
</head>
<body>

<h2 id="status">白のターン</h2>
<div class="board" id="board"></div>

<script>
const boardEl = document.getElementById("board");
const statusEl = document.getElementById("status");

const pieces = {
  "P":"♙","R":"♖","N":"♘","B":"♗","Q":"♕","K":"♔",
  "p":"♟","r":"♜","n":"♞","b":"♝","q":"♛","k":"♚"
};

let board = [
["r","n","b","q","k","b","n","r"],
["p","p","p","p","p","p","p","p"],
["","","","","","","",""],
["","","","","","","",""],
["","","","","","","",""],
["","","","","","","",""],
["P","P","P","P","P","P","P","P"],
["R","N","B","Q","K","B","N","R"]
];

let selected=null;
let turn="white";

function draw(){
  boardEl.innerHTML="";
  for(let y=0;y<8;y++){
    for(let x=0;x<8;x++){
      const c=document.createElement("div");
      c.className="cell "+((x+y)%2?"black":"white");
      if(selected && selected.x===x && selected.y===y){
        c.classList.add("selected");
      }
      c.textContent=pieces[board[y][x]]||"";
      c.onclick=()=>click(x,y);
      boardEl.appendChild(c);
    }
  }
  statusEl.textContent = turn==="white" ? "白のターン" : "黒（AI）のターン";
}

function isWhite(p){return p===p.toUpperCase();}
function isBlack(p){return p===p.toLowerCase();}

function click(x,y){
  if(turn!=="white") return;

  const p=board[y][x];

  if(selected){
    const moves=getMoves(selected.x,selected.y);
    if(moves.some(m=>m.x===x && m.y===y)){
      move(selected.x,selected.y,x,y);
      selected=null;
      turn="black";
      draw();
      setTimeout(aiMove,300);
      return;
    }
    selected=null;
  }else{
    if(p && isWhite(p)){
      selected={x,y};
    }
  }
  draw();
}

function move(sx,sy,dx,dy){
  board[dy][dx]=board[sy][sx];
  board[sy][sx]="";
}

function getMoves(x,y){
  const p=board[y][x];
  if(!p) return [];

  const moves=[];
  const dir=isWhite(p)?-1:1;

  function push(nx,ny){
    if(nx<0||ny<0||nx>7||ny>7) return;
    const target=board[ny][nx];
    if(!target || (isWhite(p)&&isBlack(target))||(isBlack(p)&&isWhite(target))){
      moves.push({x:nx,y:ny});
      return true;
    }
    return false;
  }

  switch(p.toLowerCase()){
    case "p":
      if(!board[y+dir]?.[x]) push(x,y+dir);
      if((y===6&&p==="P")||(y===1&&p==="p")){
        if(!board[y+dir]?.[x] && !board[y+2*dir]?.[x]){
          push(x,y+2*dir);
        }
      }
      [[-1,dir],[1,dir]].forEach(d=>{
        const nx=x+d[0],ny=y+d[1];
        if(board[ny]?.[nx] && ((isWhite(p)&&isBlack(board[ny][nx]))||(isBlack(p)&&isWhite(board[ny][nx])))){
          moves.push({x:nx,y:ny});
        }
      });
      break;

    case "r":
      slide([[1,0],[-1,0],[0,1],[0,-1]]);
      break;

    case "b":
      slide([[1,1],[1,-1],[-1,1],[-1,-1]]);
      break;

    case "q":
      slide([[1,0],[-1,0],[0,1],[0,-1],[1,1],[1,-1],[-1,1],[-1,-1]]);
      break;

    case "n":
      [[1,2],[2,1],[-1,2],[-2,1],[1,-2],[2,-1],[-1,-2],[-2,-1]]
      .forEach(d=>push(x+d[0],y+d[1]));
      break;

    case "k":
      [[1,0],[-1,0],[0,1],[0,-1],[1,1],[1,-1],[-1,1],[-1,-1]]
      .forEach(d=>push(x+d[0],y+d[1]));
      break;
  }

  function slide(dirs){
    dirs.forEach(d=>{
      let nx=x,ny=y;
      while(true){
        nx+=d[0]; ny+=d[1];
        if(!push(nx,ny)) break;
        if(board[ny]?.[nx]) break;
      }
    });
  }

  return moves;
}

function aiMove(){
  let all=[];
  for(let y=0;y<8;y++){
    for(let x=0;x<8;x++){
      const p=board[y][x];
      if(p && isBlack(p)){
        const moves=getMoves(x,y);
        moves.forEach(m=>{
          all.push({sx:x,sy:y,dx:m.x,dy:m.y});
        });
      }
    }
  }

  if(all.length===0){
    alert("ゲーム終了");
    return;
  }

  const m=all[Math.floor(Math.random()*all.length)];
  move(m.sx,m.sy,m.dx,m.dy);

  turn="white";
  draw();
}

draw();
</script>

</body>
</html>
