/* 
    Test if text field is date, return logical.
    This version of IsDate checks that the original text matches the reformatted date text, adding an additional layer of validation.
*/

IsDate = (text) => 
    let 
        parsed = try Date.FromText(text),
        reformatted = try Date.ToText(parsed[Value], "dd.MM.yyyy")
    in 
        not parsed[HasError] and not reformatted[HasError] and text = reformatted[Value]
