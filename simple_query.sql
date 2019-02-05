
--showing username, balance, total_data, total_talk_time, total_sms
select user_name, balance, total_mb, total_talk_time, total_offer_sms
from users where mobile_number = 1755840785;

--showing call_history
select call_number, to_char(h_date, 'YYYY-MM-DD HH12:MI:SS PM') as date, cost, type
from call_history where user_id = 1755840785;

--showing sms_history
select sms_number, to_char(h_date, 'YYYY-MM-DD HH12:MI:SS PM') as date, cost, type
from sms_history where user_id = 1755840785;

--showing internet_history
select mb_used, to_char(h_date, 'YYYY-MM-DD HH12:MI:SS PM') as date
from internet_history where user_id = 1755840785;

--showing recharge_history
select amount, validity, to_char(h_date, 'YYYY-MM HH12:MI:SS PM') as recharged_time
from recharge_history where  user_id = 1755840785;

--showing reward_offer
select mb_amount, points_need, validity
from reward_offer;

--showing talk_time_offer
select talk_time, validity, price, reward_points
from talk_time_offer;

--showing sms_offer
select sms_amount, validity, price, reward_points
from sms_offer;

--showing data_offer
select data_amount, validity, price, reward_points
from internet_offer;

--showing packages
select package_name, call_rate, data_rate, fnf_limit
from package;

--showing notifications
select message from notifications
where user_id = 1755840785;

--checking star status
select type from star where star_id = (
  select star_id from users
  where mobile_number = 01787571128 and star.star_id is not null
  );

-- fkldfslkjsldk

 select PRICE from internet_offer
  where OFFER_ID in (
    select OFFER_ID from PURCHASE_OFFER
    where USER_ID = 01787571128 and (now() - PURCHASE_DATE) < interval '1 day' * 90
  );



do $$
declare
  total_usage_last3months numeric;
  prc numeric;
  curr_date timestamptz;
  str_id numeric;
  usage_tobe_star numeric;
  r cursor for
    select * from star;
  off_id cursor for
    select OFFER_ID from PURCHASE_OFFER
    where USER_ID = new.user_id and (curr_date - PURCHASE_DATE) < interval '1 day' * 90;
begin
  curr_date := now();
  total_usage_last3months := 0;

  for b in off_id
  loop
    select price into prc from internet_offer where offer_id = b.offer_id;
    total_usage_last3months := total_usage_last3months + prc;
  end loop;

  for a in r
  loop
    str_id := a.star_id;
    usage_tobe_star := a.average_uses;
    if total_usage_last3months >= usage_tobe_star then
      --update users set STAR_ID = str_id where MOBILE_NUMBER = new.user_id;
      --return new;
      raise notice 'haha he is ' || a.type;
    end if;
  end loop;
  --return new;
end;
$$ language plpgsql;
