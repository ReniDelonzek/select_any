enum ButtonPosition { APPBAR, BOTTOM, IN_TABLE }

ButtonPosition getDefaultButtonPosition(int typeScreen) {
  if (typeScreen == 1) {
    return ButtonPosition.BOTTOM;
  }
  return ButtonPosition.IN_TABLE;
}
