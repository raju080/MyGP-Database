
create or replace function check_star_function() returns trigger as $$
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
      update users set STAR_ID = str_id where MOBILE_NUMBER = new.user_id;
      --return new;
      exit ;
      --raise notice 'haha he is ' || a.type;
    end if;
  end loop;
  return new;
end;
$$ language plpgsql;

create or replace function insert_pk_to_offer() returns trigger as $$
begin
  insert into offers values (new.offer_id);
  return new;
end;
$$ language plpgsql;



drop trigger if exists insert_internet_pk_to_parent on internet_offer;
create trigger insert_internet_pk_to_parent after insert on internet_offer
for each row
  execute procedure insert_pk_to_offer();


drop trigger if exists insert_talk_time_pk_to_parent on talk_time_offer;
create trigger insert_talk_time_pk_to_parent after insert on talk_time_offer
for each row
  execute procedure insert_pk_to_offer();

drop trigger if exists insert_sms_pk_to_parent on sms_offer;
create trigger insert_sms_pk_to_parent after insert on sms_offer
for each row
  execute procedure insert_pk_to_offer();

drop trigger if exists insert_reward_pk_to_parent on reward_offer;
create trigger insert_reward_pk_to_parent after insert on reward_offer
for each row
  execute procedure insert_pk_to_offer();

drop trigger if exists insert_general_pk_to_parent on general_offer;
create trigger insert_general_pk_to_parent after insert on general_offer
for each row
  execute procedure insert_pk_to_offer();

drop trigger if exists check_star on purchase_offer;
create trigger check_star after insert on purchase_offer
for each row
  execute procedure check_star_function();





/*CREATE TRIGGER PURCHASE_TRIGGER AFTER INSERT ON OFFERS
  FOR EACH ROW
  EXECUTE PROCEDURE INSERT_PURCHASE_OFFER_ROW()
*/
/*CREATE OR REPLACE FUNCTION INSERT_PURCHASE_OFFER_ROW(IN MOB NUMERIC, IN OFFER_NO NUMERIC, IN PURCHASED_TIME TIMESTAMPTZ)
  RETURNS TRIGGER AS $$
DECLARE
BEGIN
  INSERT INTO PURCHASE_OFFER VALUES(MOB, OFFER_NO, PURCHASED_TIME);
end;
$$ language plpgsql;

  select * from star;*/