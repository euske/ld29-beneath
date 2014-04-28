package {

public class Skin
{
  public static const PLAYER_FRONT:int = 0;

  public static const PLAYER_WALKING:int = 2;
  public static const PLAYER_WALKING_PHASES:int = 4;

  public static const PLAYER_DIGGING:int = 10;
  public static const PLAYER_DIGGING_PHASES:int = 4;

  public static const PLAYER_CLIMBING:int = 18;
  public static const PLAYER_CLIMBING_PHASES:int = 4;

  public static const PLAYER_HURTING:int = 26;

  public static const PLAYER_CHEERING:int = 28;

  public static const MOLE_RUNNING:int = 36;
  public static const MOLE_RUNNING_PHASES:int = 3;

  public static const ROBOCAKE:int = 42;
  public static const ROBOCAKE_PHASES:int = 4;

  public static function playerWalking(phase:int):int
  {
    phase = phase % PLAYER_WALKING_PHASES; // 0->1->2->3->0
    return PLAYER_WALKING + phase*2;
  }

  public static function playerDigging(phase:int):int
  {
    phase = phase % PLAYER_DIGGING_PHASES;
    return PLAYER_DIGGING + phase*2;
  }

  public static function playerClimbing(phase:int):int
  {
    phase = phase % PLAYER_CLIMBING_PHASES;
    return PLAYER_CLIMBING + phase*2;
  }
  
  public static function playerHurting(phase:int):int
  {
    return PLAYER_HURTING;
  }

  public static function moleRunning(phase:int):int
  {
    phase = phase % MOLE_RUNNING_PHASES;
    return MOLE_RUNNING + phase*2;
  }

}

}
