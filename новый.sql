
from sqlalchemy import create_engine, Column, Integer, String, ForeignKey, Table
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship, sessionmaker


DATABASE_URI = 'mysql+pymysql://root:2609@localhost:3306/vk'
engine = create_engine(DATABASE_URI, echo=False)
Base = declarative_base()


class User(Base):
    __tablename__ = 'users'

    id = Column(Integer, primary_key=True, autoincrement=True)
    firstname = Column(String, nullable=False)
    lastname = Column(String, nullable=False)
    phone = Column(String, nullable=False, unique=True)

    def __repr__(self):
        return f"<User(name={self.firstname} {self.lastname}, phone={self.phone})>"


class Company(Base):
    __tablename__ = 'companies'

    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String, nullable=False)

    def __repr__(self):
        return f"<Company(id={self.id}, name={self.name})>"


class Question(Base):
    __tablename__ = 'questions'

    id = Column(Integer, primary_key=True, autoincrement=True)
    content = Column(String, nullable=False)
    
    def __repr__(self):
        return f"<Question(id={self.id}, content={self.content})>"

Company.questions = relationship('Question', order_by=Question.id, back_populates='company')


class Answer(Base):
    __tablename__ = 'answers'

    id = Column(Integer, primary_key=True, autoincrement=True)
    question_id = Column(Integer, ForeignKey('questions.id'), nullable=False)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    answer = Column(String, nullable=False)

    user = relationship("User")
    question = relationship("Question")

    def __repr__(self):
        return f"<Answer(id={self.id}, question_id={self.question_id}, user_id={self.user_id}, answer={self.answer})>"


Base.metadata.create_all(engine)


Session = sessionmaker(bind=engine)
session = Session()


def greet_user_by_phone():
   
    while True:
        phone_input = input('Введите ваш номер телефона (формат: +1234567890): ')
        user = session.query(User).filter_by(phone=phone_input).first()

        if user:
            print(f"Здравствуйте, {user.firstname} {user.lastname}")
            return user
        else:
            print("Номер телефона не найден в базе данных, пожалуйста, попробуйте еще раз.")

def get_company_choice():
  
    print("Список доступных компаний:")
    companies = session.query(Company).limit(10).all()
    for company in companies:
        print(f"{company.id}. {company.name}")

    while True:
        company_id_input = inputnВведите ID компании, которую вы выбираете: ")
        try:
            selected_company = session.query(Company).filter_by(id=int(company_id_input)).first()
            if selected_company:
                print(f"Вы выбрали компанию: {selected_company.name}")
                return selected_company
            else:
                raise ValueError
        except ValueError:
            print("Некорректный выбор, попробуйте снова.")

def select_question_for_answer(company):
    
    print(f"Список вопросов для компании {company.name}:")
    questions = session.query(Question).filter_by(company_id=company.id).limit(10).all()
    for question in questions:
        print(f"{question.id}. {question.content}")

    while True:
        question_id_input = input(Введите ID вопроса, на который хотите ответить: ")
        try:
            selected_question = session.query(Question).filter_by(id=int(question_id_input)).first()
            if selected_question:
                print(f"Вы выбрали вопрос: {selected_question.content}")
                return selected_question
            else:
                raise ValueError
        except ValueError:
            print("Некорректный выбор, попробуйте снова.")

def record_answer(user, question):
   
    answer_content = input(f"Ваш ответ на вопрос '{question.content}': ")

    
    new_answer = Answer(question_id=question.id, user_id=user.id, answer=answer_content)
    session.add(new_answer)
    session.commit()

    print("Ваш ответ успешно сохранён.")

def main():
    
    user = greet_user_by_phone()

   
    company = get_company_choice()

   
    question = select_question_for_answer(company)

    
    record_answer(user, question)
    
    print("Спасибо за участие!")

if __name__ == '__main__':
    main()

