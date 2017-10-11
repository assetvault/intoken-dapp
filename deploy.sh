. /root/.nix-profile/etc/profile.d/nix.sh

export INBOT_TT_ADDRESS=`dapp create TrustToken -F $1 -G $2` 
export INBOT_TG_ADDRESS=`dapp create TrustGuard -F $1 -G $2` 
export INBOT_TP_ADDRESS=`dapp create TrustPricing -F $1 -G $2`
export INBOT_TS_ADDRESS=`dapp create TrustScoring -F $1 -G $2`
export INBOT_TM_ADDRESS=`dapp create TrustMediator -F $1 -G $2`
export INBOT_IUI_ADDRESS=`dapp create InbotUserInfo -F $1 -G $2`
export INBOT_TSM_ADDRESS=`dapp create TrustShareManager -F $1 -G $2`
export INBOT_PROXY_ADDRESS=`dapp create TrustProxy $INBOT_T_ADDRESS $INBOT_TP_ADDRESS $INBOT_TS_ADDRESS $INBOT_IUI_ADDRESS $INBOT_TM_ADDRESS $INBOT_TSM_ADDRESS -F $1 -G $2`

env | grep '^INBOT_' | cat >env.variables

(set -x; seth send $INBOT_TP_ADDRESS 'setProxy(address)' $INBOT_PROXY_ADDRESS -F $1)
(set -x; seth send $INBOT_TM_ADDRESS 'setProxy(address)' $INBOT_PROXY_ADDRESS -F $1)
(set -x; seth send $INBOT_TSM_ADDRESS 'setProxy(address)' $INBOT_PROXY_ADDRESS -F $1)

export ANY_SIG=`seth --to-bytes32 0`

(set -x; seth send $INBOT_TG_ADDRESS 'permit(address,address,bytes32)' $INBOT_TM_ADDRESS $INBOT_TS_ADDRESS $ANY_SIG -F $1)
(set -x; seth send $INBOT_TG_ADDRESS 'permit(address,address,bytes32)' $INBOT_TM_ADDRESS $INBOT_TSM_ADDRESS $ANY_SIG -F $1)
(set -x; seth send $INBOT_TG_ADDRESS 'permit(address,address,bytes32)' $INBOT_TM_ADDRESS $INBOT_TT_ADDRESS $ANY_SIG -F $1)
(set -x; seth send $INBOT_TG_ADDRESS 'permit(address,address,bytes32)' $INBOT_TSM_ADDRESS $INBOT_TT_ADDRESS $ANY_SIG -F $1)

(set -x; seth send $INBOT_TS_ADDRESS 'setAuthority(address)' $INBOT_TG_ADDRESS -F $1)
(set -x; seth send $INBOT_TM_ADDRESS 'setAuthority(address)' $INBOT_TG_ADDRESS -F $1)
(set -x; seth send $INBOT_TT_ADDRESS 'setAuthority(address)' $INBOT_TG_ADDRESS -F $1)