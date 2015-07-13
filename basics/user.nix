uid: name:
{ home ? "/home/${username}"
, createHome ? true
, isNormalUser ? true
, isSystemUser ? false
, group ? "users"
, extraGroups ? [ "audio" "vboxusers" ]
, authorizedKeys ? [ (import "../keys/${username}.id_rsa.pub") ]
, ... }:
{
  inherit uid name home createHome
  inherit isNormalUser isSystemUser;
  inherit extraGroups group;

  openssh.authorizedKeys.keys = authorizedKeys;
}
