select * from clients;
select * from contracts;
select * from installments_paid;
---------------------------------------------------------
declare
                cursor data_cursor is
                select *
                from clients cl ,contracts co
                where cl.client_id = co.client_id
                order by cl.client_id;
                v_count number(4);
                v_installment_date date;
begin

        for data_record in data_cursor loop
                   select count(*) 
                   into v_count from contracts where contract_id = data_record.contract_id;
                   if v_count < 1 then 
                            v_installment_date := data_record.contract_start_date;
                   else 
                            if data_record.contract_paymnet_type = 'ANNUAL' then
                                            
                                            v_installment_date := add_months(data_record.contract_start_date , 12);
                            elsif data_record.contract_paymnet_type = 'QUARTER' then
                                                v_installment_date := add_months(data_record.contract_start_date , 3);
                            elsif data_record.contract_paymnet_type = 'HALF_ANNUAL' then
                                                v_installment_date := add_months(data_record.contract_start_date , 6); 
                            else
                                                v_installment_date := add_months(data_record.contract_start_date , 1);                                                          
                            end if;        
                   end if; 
        end loop;
end;