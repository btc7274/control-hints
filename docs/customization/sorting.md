# Sorting

All KeyCodes are sorted in a specific pattern inside the `KeyCodeSorting` ModuleScript under `Configuration`. Hints with certain KeyCodes, like a mouse click, will take priority over other hints by having a lower index, thus having a lower LayoutOrder and displaying closer to the top.

The order in which KeyCodes are sorted can be easily modified by shuffling keys up and down the list in `KeyCodeSorting`. KeyCodes at the top of the list will display at the top, while KeyCodes at the bottom of the list will display at the bottom.

You can modify this behavior by setting a [`CustomOrder` attribute](attributes.md) (number) to the InputAction of the hint. This is especially useful if you have a hint that you always want to appear at the top or bottom. In such a case, you'd set the `CustomOrder` attribute to an impossibly low or high number, like -1 or 9999.
