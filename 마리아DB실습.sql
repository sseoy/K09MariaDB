
/*
블럭단위 주석
*/
#라인단위 주석1
-- 라인단위 주석2

SELECT * from ts_test;

#모델1방식(JSP) + MariaDB를 이용한 게시판
#회원테이블 (부모)
create table member(
    id VARCHAR(30) not null,
    pass VARCHAR(30) not null,
    name VARCHAR(30) not null,
    regidate datetime default CURRENT_TIMESTAMP,/*현재시간을 디폴트로 사용
    											datatime : 날짜와 시간을 동시에 표현할수있는 자료형*/
    primary key(id)
);
DROP TABLE member;

#게시판 테이블(자식)
/*
	AUTO_INCREMENT : 오라클의 시퀀스를 대체할수 있는 속성으로
		지정된 컬럼은 자동으로 값이 증가하게 된다. 단 자동증가로
		지정되면 컬럼은 데이터를  임의로 삽입할 수 없게된다.
*/
create table board(
    num INT NOT NULL auto_increment,
    title VARCHAR(100) not null,
    content text not null,
    postdate datetime default current_timestamp,
    id varchar(30) not null,
    visitcount mediumint(10) NOT NULL DEFAULT 0,
    PRIMARY KEY (num)
);


#회원테이블과 게시판테이블의 참조 제약조건
ALTER TABLE board ADD constraint fk_board_member
	FOREIGN KEY (id) REFERENCES member(id);

#더미데이터 삽입
INSERT INTO member(id, pass, NAME)VALUES('kosmo','1234', 'kosmo61기');
#member테이블과 외래키 제약조건이 있으므로 board테이블에 먼저 삽입할 경우
#에러가 발생된다.
INSERT INTO board (title, content, id)
	VALUES('제목입니다1', '내용입니다1', 'kosmo');
INSERT INTO board (title, content, id)
	VALUES('제목입니다2', '내용입니다2', 'kosmo');
INSERT INTO board (title, content, id)
	VALUES('제목입니다3', '내용입니다3', 'kosmo');
INSERT INTO board (title, content, id)
	VALUES('제목입니다4', '내용입니다4', 'kosmo');
INSERT INTO board (title, content, id)
	VALUES('제목입니다5', '내용입니다5', 'kosmo');	



#데이터타입
#숫자형
CREATE TABLE tb_int (
	idx INT PRIMARY KEY AUTO_INCREMENT,
	
	num1 TINYINT UNSIGNED NOT NULL,
	num2 SMALLINT NOT NULL,
	num3 MEDIUMINT DEFAULT '100',
	num4 BIGINT,
	
	fnum1 FLOAT(10,5) NOT NULL,
	fnum2 double(20,10)
);


INSERT INTO tb_int(num1, num2, num3, num4, fnum1, fnum2)
	VALUES(100, 12345, 1234567, 1234567890, 
		12345.12345, 1234567890.1234567891);

SELECT * FROM tb_int;

/* 자동증가 컬럼에 임의의값을 삽입할수 있으나 사용하지 않는것이
좋다. */
INSERT INTO tb_int(idx, num1, num2, num3, num4, fnum1, fnum2)
	VALUES(2, 100, 12345, 1234567, 1234567890, 
		12345.12345, 1234567890.1234567891);

/*빈값은 삽입할수 없다. 오류발생됨.*/
INSERT INTO tb_int(idx, num1, num2, num3, num4, fnum1, fnum2)
	VALUES('', 100, 12345, 1234567, 1234567890, 
		12345.12345, 1234567890.1234567891);

#날짜형
CREATE TABLE tb_date(
	idx INT PRIMARY KEY AUTO_INCREMENT,
	
	DATE1 DATE NOT NULL,
	DATE2 DATETIME DEFAULT current_timestamp
);
/*
날짜타입의 컬럼에 현재날자를 입력할때 오라클은 sysdate를
사용하지만MYSQL은 now()함수를 사용한다.
*/
INSERT INTO tb_date(DATE1, DATE2)
	VALUES('2020-05-27', NOW());
SELECT * FROM tb_date;
/*
시간변화함수 dotd)fermat(컬럼명, '서식')
*/
SELECT DATE_FORMAT(DATE2, '%Y-%m-%d')FROM tb_date;#년-월-일

SELECT DATE_FORMAT(DATE2, '%H:%i:%s')FROM tb_date;#시,분,초

#특수형
CREATE TABLE tb_spec(

	idx INT AUTO_INCREMENT,
	
	spec1 ENUM('M', 'W', 'T'),
	spec2 set('A', 'B', 'C', 'D'),
tb_spec	PRIMARY KEY(IDX)
);


SELECT *FRRM TB_SEPC;
INSERT INTO tb_spec(SPEC1, SPEC2)
	VALUES('w', 'A,B,D');
INSERT INTO tb_spec(SPEC2)
	VALUES('A,B,D');
INSERT INTO tb_spec(SPEC1, SPEC2)
	VALUES('w', 'A,B,D');
	





/*
Model1 방식의 게시판을 MariaDB로 컨버팅
*/
#전체 레코드 수 조회 
SELECT COUNT(*) FROM board;
SELECT COUNT(*) FROM board WHERE title LIKE '%다1%';


-- 페이지처리를 위한 쿼리문(오라클과 다름)
SELECT * FROM board ORDER BY num desc;

-- 1페이지에 2개의 게시물이 출력된다고 가졍했을때
/*
페이지처리를 위해 게시물의 범위를정할때 Oracle은 rownum의
속성을 사용하지만 MariaDB는 limit를 사용한다.
방법 : limit 시작 인덱스, 가져올레코드갯수
*/
-- 1페이지 레코드 셋
SELECT * FROM board ORDER BY num DESC LIMIT 0, 2;
-- 2페이지 레코드 셋
SELECT * FROM board ORDER BY num DESC LIMIT 2, 2;
-- 3페이지 레코드 셋
SELECT * FROM board ORDER BY num DESC LIMIT 4, 2;


-- 상세보기 처리 -  조회수 업데이트
UPDATE board SET visitcount = visitcount+1 WHERE num=2;
SELECT * FROM board WHERE num=2;

-- 회원테이블과 게시판 테이블 내부조인을 통한 조회
#표준SQL 방식
SELECT
	B.*, M.name
FROM member M INNER JOIN board B
	ON M.id =B.id
WHERE num=2;


#간단방식
SELECT
	B.*, M.name
FROM member M, board B
WHERE
	M.id=B.id AND num=2;



-- 게시물 수정하기
UPDATE board SET
	title='수정해볼까요?', content='수정은 수정일뿐ㅋㅋ'
WHERE num=2;


-- 게시물 삭제하기
DELETE FROM board WHERE num=2;


/*
기존의 게시판을 멀티게시판으로 변경
	자유게시판 :  freeboard
	공지사항  : notice
	질문과답변 : qna
	FAQ : faq
하나의 테이블로 여러개의 게시판을 제작하는 경우 게시판의 구분을 위해
flag(플레그)가 필요하다.
*/
-- 공지사항 게시판에 글쓰기
INSERT INTO board (title, content, id, bname)
	VALUE ('여긴 공지사항', '내용없음', 'kosmo', 'notice');

-- 자유 게시판 리스트 보기
SELECT * FROM board WHERE bname='freeboard';
-- 공지사항 리스트 보기
SELECT * FROM board WHERE bname='notice';


create table board(
    num INT NOT NULL auto_increment,
    title VARCHAR(100) not null,
    content text not null,
    postdate datetime default current_timestamp,
    id varchar(30) not null,
    visitcount mediumint(10) NOT NULL DEFAULT 0,
    PRIMARY KEY (num)
);




create table multi_board(
    num INT NOT NULL auto_increment,
    id varchar(30) not null,
    title VARCHAR(100) not null,
    pass VARCHAR(30) NOT NULL,
    content text not null,multi_board
    postdate datetime default current_timestamp,
    visitcount mediumint(10) NOT NULL DEFAULT 0,
    attachedfile VARCHAR(100),
    downcount INT DEFAULT 0,
    bname VARCHAR(50) NOT NULL,
    PRIMARY KEY (num)
);


create table membership(
    name VARCHAR(30) not null,
    id VARCHAR(30) not null,
    pass VARCHAR(30) not null,
    tel VARCHAR(30) DEFAULT 0,
    mobile VARCHAR(30) not null,
    email VARCHAR(30) NOT NULL,
    zip VARCHAR(500) NOT NULL,
    joindate DATETIME DEFAULT CURRENT_TIMESTAMP,
    grade INT DEFAULT 1,
    
    PRIMARY KEY(id)membership
);


insert INTO membership( name, id, pass, mobile, email, zip, grade)
 VALUES('관리자', 'kosmo1', '1234','010-5597-1287', 'aflj1287@naver.com',  '서울특별시 가산동 147-31', 3);

SELECT COUNT(*) FROM membership WHERE id LIKE 'ko%';

SELECT * FROM membership WHERE grade='1'; 

SELECT * FROM membership WHERE grade='1'        ORDER BY name DESC;


SELECT * FROM membership WHERE grade='1'        ORDER BY name DESC LIMIT 0, 2;


INSERT INTO membership(NAME, id, pass, tell, mobile, email, addr, zip, emailcheck, addrdetail)
	VALUES('1', '1', '1', '1','1','1','1','1','1','1');
	
UPDATE membership SET NAME='hhh', tell='hhh', mobile='hhh', email='hhh', grade='2', zip='12354', addr='hhh', addrdetail='hhh' WHERE id='2';


ALTER TABLE multi_board ADD constraint fk_board_member
	FOREIGN KEY (id) REFERENCES membership(id) ON DELETE cascade;

INSERT INTO multi_board (id, title, content, bname)
	VALUE ('kosmo', '안녕하세요 여기는 공지사항 제목 글자수 오버로딩 테스트중입ㄴ니다.','자유게시판 내용2', 'notice');
	
INSERT INTO multi_board (id, title, content, bname, scheduledate )
	VALUE ('kosmo', '안녕하세요 여기는 프로그램 일정 ','프로그램 일정2','schedule' ,'20200515' );


INSERT INTO multi_board ( title,content,id,visitcount, bname)    VALUES ( '1111','1111','kosmo',0,'1111');

ALTER TABLE multi_board DROP CONSTRAINT fk_board_member;

SELECTmembership
	B.*, M.name
FROM multi_board B INNER JOIN membership M 
ON M.id = B.id
WHERE bname='notice'
 ORDER BY num DESC LIMIT 1, 2;
 
 
constrint fk_board_member FOREIGN KEY REFERENCES membership(id) ON DELETE casecade;
 
 
 create table request_form(
    r_num INT NOT NULL auto_increment,
    r_id varchar(30) not null,
    r_addr VARCHAR(300) not null,
    r_tel VARCHAR(30) NOT NULL,
    r_phone VARCHAR(30) NOT NULL,
    r_email VARCHAR(100) NOT NULL,
    cleaningtype VARCHAR(100),
    pyeong int,
    r_date VARCHAR(30) NOT NULL,
    postdate datetime default current_timestamp,
    receip VARCHAR(200) ,
    r_request VARCHAR(30) NOT NULrequest_formL,
    PRIMARY KEY (r_num)
);

ALTER TABLE request_form DROP CONSTRAINT fk_request_member;
ALTER TABLE request_form ADD constraint fk_request_member
	FOREIGN KEY (r_id) REFERENCES membership(id) ON DELETE cascade;