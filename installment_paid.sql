
declare
                cursor data_cursor is
                    select  *
                     from CLIENTS clt inner join contracts con
                    on CLT.CLIENT_ID = con.client_id; 
                v_count number(4);
                v_installment_date date; 
                no_of_installments number(10,2);
                v_installment_amount number(10,2);       
                v_max_date date;
                v_sum number(10,2);
                
begin

     for data_record in data_cursor loop
            select count(contract_id) into v_count from installments_paid where contract_id = data_record.contract_id;
            select nvl(max(v_installment_amount) ,0) into v_sum from installments_paid where contract_id = data_record.contract_id;
            select nvl(max(v_installment_date) , min(data_record.contract_startdate)) into v_max_date from installments_paid where contract_id = data_record.contract_id; 
            
                   if v_count <1 then
                                     v_installment_date := data_record.contract_startdate;
                                    if data_record.contract_payment_type = 'ANNUAL' then
                                                no_of_installments :=  trunc(months_between(data_record.contract_enddate , data_record.contract_startdate)/12);
                                                v_installment_amount := (data_record.contract_total_fees - nvl(data_record.contract_deposit_fees,0)) / no_of_installments;
                                    elsif  data_record.contract_payment_type = 'QUARTER' then
                                                 no_of_installments := trunc(months_between(data_record.contract_enddate , data_record.contract_startdate)/3);
                                                v_installment_amount := (data_record.contract_total_fees - nvl(data_record.contract_deposit_fees,0)) / no_of_installments;   
                                     elsif  data_record.contract_payment_type = 'HALF_ANNUAL' then
                                                 no_of_installments :=  trunc(months_between(data_record.contract_enddate , data_record.contract_startdate)/6);
                                                v_installment_amount := (data_record.contract_total_fees - nvl(data_record.contract_deposit_fees,0))/ no_of_installments; 
                                    else
                                                 no_of_installments := trunc(months_between(data_record.contract_enddate , data_record.contract_startdate));
                                                 v_installment_amount := (data_record.contract_total_fees - nvl(data_record.contract_deposit_fees,0))/ no_of_installments;  
                                    end if;                                        
                   elsif  v_count >= 1 and v_sum < data_record.contract_total_fees and  v_max_date <  data_record.contract_enddate  then 
                                    if data_record.contract_payment_type = 'ANNUAL' then
                                                no_of_installments :=  trunc(months_between(data_record.contract_enddate , data_record.contract_startdate)/12);
                                                v_installment_amount := (data_record.contract_total_fees - nvl(data_record.contract_deposit_fees,0)) / no_of_installments;
                                                v_installment_date := add_months(data_record.contract_startdate , 12);
                                    elsif  data_record.contract_payment_type = 'QUARTER' then
                                                 no_of_installments := trunc(months_between(data_record.contract_enddate , data_record.contract_startdate)/3);
                                                 v_installment_amount := (data_record.contract_total_fees - nvl(data_record.contract_deposit_fees,0)) / no_of_installments;   
                                                 v_installment_date := add_months(data_record.contract_startdate , 3);
                                     elsif  data_record.contract_payment_type = 'HALF_ANNUAL' then
                                                 no_of_installments :=  trunc(months_between(data_record.contract_enddate , data_record.contract_startdate)/6);
                                                 v_installment_amount := (data_record.contract_total_fees - nvl(data_record.contract_deposit_fees,0))/ no_of_installments; 
                                                 v_installment_date := add_months(data_record.contract_startdate , 6); 
                                    else
                                                 no_of_installments := trunc(months_between(data_record.contract_enddate , data_record.contract_startdate));
                                                 v_installment_amount := (data_record.contract_total_fees - nvl(data_record.contract_deposit_fees,0))/ no_of_installments;     
                                                 v_installment_date := add_months(data_record.contract_startdate , 1);                                                                                                                
                                    end if;
                    
                                                                     
                   end if;
                   insert into  installments_paid values (INSTALLMENTS_PAID_SEQ.nextval , data_record.contract_id , v_installment_date , v_installment_amount , 0  ) ;     
                    
     end loop;

end;

show errors;