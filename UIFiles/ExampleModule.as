package  {
    
    import flash.display.MovieClip;
    //we have to import mouse events so flash knows what we're talking about
    import flash.events.MouseEvent;
    import flash.display.Shape;
	
    
    public class ExampleModule extends MovieClip {
		var gameAPI:Object;
		var globals:Object;
		var colorSquareArray:Array;
		var playerColors:Array;
		var playerColorIndices:Array;
		var teamToPlayerIndices:Array;
		var playerIncomes:Array;
		var playerUnits:Array;
		
        public function ExampleModule() {
            //we add a listener to this.button1 (I called my button 'button1')
            //this listener listens to the CLICK mouseEvent, and when it observes it, it cals onButtonClicked
            //this.button1.addEventListener(MouseEvent.CLICK, onButtonClicked);
			
			playerColors = new Array();
			playerColors[2] = 0x99FFFF; // teal
			playerColors[3] = 0xFFFF00; // yellow
			playerColors[6] = 0xFF99CC; // pink
			playerColors[7] = 0xFF9900; // orange
			playerColors[8] = 0x0066FF; // blue
			playerColors[9] = 0x009900; // green
			playerColors[10] = 0x663300; // brown
			playerColors[11] = 0x0099CC; // cyan
			playerColors[12] = 0x666600; // olive
			playerColors[13] = 0x663399; // purple
			
			playerColorIndices = new Array();
			playerColorIndices[0] = 2;
			playerColorIndices[1] = 3;
			playerColorIndices[2] = 6;
			playerColorIndices[3] = 7;
			playerColorIndices[4] = 8;
			playerColorIndices[5] = 9;
			playerColorIndices[6] = 10;
			playerColorIndices[7] = 11;
			playerColorIndices[8] = 12;
			playerColorIndices[9] = 13;
			
			teamToPlayerIndices = new Array();
			teamToPlayerIndices[2] = 0;
			teamToPlayerIndices[3] = 1;
			teamToPlayerIndices[6] = 2;
			teamToPlayerIndices[7] = 3;
			teamToPlayerIndices[8] = 4;
			teamToPlayerIndices[9] = 5;
			teamToPlayerIndices[10] = 6;
			teamToPlayerIndices[11] = 7;
			teamToPlayerIndices[12] = 8;
			teamToPlayerIndices[13] = 9;
			
			playerIncomes = new Array();
			playerIncomes[0] = this.player0Income;
			playerIncomes[1] = this.player1Income;
			playerIncomes[2] = this.player2Income;
			playerIncomes[3] = this.player3Income;
			playerIncomes[4] = this.player4Income;
			playerIncomes[5] = this.player5Income;
			playerIncomes[6] = this.player6Income;
			playerIncomes[7] = this.player7Income;
			playerIncomes[8] = this.player8Income;
			playerIncomes[9] = this.player9Income;
			
			playerUnits = new Array();
			playerUnits[0] = this.player0Units;
			playerUnits[1] = this.player1Units;
			playerUnits[2] = this.player2Units;
			playerUnits[3] = this.player3Units;
			playerUnits[4] = this.player4Units;
			playerUnits[5] = this.player5Units;
			playerUnits[6] = this.player6Units;
			playerUnits[7] = this.player7Units;
			playerUnits[8] = this.player8Units;
			playerUnits[9] = this.player9Units;
			
			
			colorSquareArray = new Array();
			// Initialize the player color squares (horizontal starts at -139, vertical starts at -99.6 and they are 20 by 20
			var playerNumber:int;
			for (playerNumber = 0; playerNumber < 10; playerNumber++)
			{
				var square:Shape = new Shape();
				square.graphics.beginFill(playerColors[playerColorIndices[playerNumber]], 1.0);
				square.graphics.drawRect(-139, -99.6 + (22 * playerNumber), 20, 20);
				square.graphics.endFill();
				this.addChild(square);
				colorSquareArray[playerNumber] = square;
			}
			
			
        }
		
		//set initialise this instance's gameAPI
		public function setup(api:Object, globals:Object) {
			trace("Setup is happening on the UI side and I can also view these statements!!!!!")
			this.gameAPI = api;
			
			this.globals = globals;
			//this is our listener for the event, onGoldUpdate() is the handler
			this.gameAPI.SubscribeToGameEvent("player_unit_count_changed", this.onUnitCountChanged);
			this.gameAPI.SubscribeToGameEvent("player_income_changed", this.onIncomeChanged);
			
		}
		
		private function onButtonClicked(event:MouseEvent) : void {
			this.gameAPI.SendServerCommand("ExampleCommand 1");
		}
		
		public function onUnitCountChanged(args:Object) : void {
			//get the ID of the player this UI belongs to, here we use a scaleform function from globals
			//var pID:int = globals.Players.GetLocalPlayer();
			
			//check of the player in the event is the owner of this UI. Note that args are the parameters of the event
			//if (args.player_ID == pID) 
			//{
			//}
			
			playerUnits[teamToPlayerIndices[args.teamNumber]].text = args.newUnitCount + "/50";
			
			trace("The unit count change message was received!!");
			//this.textToModify.text = args.newUnitCount + "/50";
			
			//var square:Shape = new Shape();
			//square.graphics.beginFill(0x9900FF, 1.0);
			//square.graphics.drawRect(-139, -99.6, 20, 20);
			//square.graphics.endFill();
			//this.addChild(square);
		}
		
		public function onIncomeChanged(args:Object) : void
		{
			playerIncomes[teamToPlayerIndices[args.teamNumber]].text = args.newIncome;
		}
		
		
		
		//we define a public function, because we call it from outside our module object.
		//we get four parameters, the stage's dimensions and the scale ratios. Flash does not have floats, we use Number for that.
		//you might wonder what happened to the ': void'. Whenever that is not added, void is assumed
		public function screenResize(stageW:int, stageH:int, scaleRatio:Number){
			//we set the position of this movieclip to the center of the stage
			//remember, the black cross in the center is our center. You control the alignment with this code, you can align your module however you like.
			this.x = stageW - 70;
		}
    }
	
	
	
}
